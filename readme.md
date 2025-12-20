# Microservices Toolbox

<p>
  <img src="https://github.com/xshadowlegendx/microservices-toolbox/actions/workflows/ci.yml/badge.svg"/>
  <img src="https://img.shields.io/docker/pulls/shadowlegend/microservices-toolbox"/>
</p>

A lightweight container image bundling tools for quick and common automation

## Tools Included
- `aws-cli`
- `kubectl` v1.34.0
- `psql` (PostgreSQL client 16)
- `jq` v1.8.1
- `yq` v4.48.1
- `nats` v0.3.0
- `miller` v6.15.0
- `jsonnet`
- `gomplate`
- `jo`
- `m4`
- `openssl`
- `uuidgen`
- `curl`
- `unzip`

## Getting started
```bash
docker run --rm -it shadowlegend/microservices-toolbox:latest jo hello=world
```

## Use cases
### Send alert to telegram on some cdc event
```bash
# below demo assuming u already have
# jo, docker, nats-cli installed
# and on some kind of *nix system
docker container run --rm -d -p 24112:4222 nats:2.12-alpine -js
while ! nc -z localhost 24112; do   
  sleep 0.5
done
nats --server localhost:24112 stream create myapp-cdc --defaults --subjects 'myapp-cdc.orders.*.*'
nats --server localhost:24112 consumer add myapp-cdc orders-placed-notifier --filter 'myapp-cdc.orders.*.placed' --defaults --pull
kind create cluster --name tele-alert-demo-$(uuid | cut -c 1-8)
# we will be using rbaskets to replace telegram as demo
cat <<EOF | sed 's/https:\/\/api\.telegram\.org\/\$telebotToken\/sendMessage/http:\/\/localhost:55555\/test/' | kubectl apply -f -
---
apiVersion: v1
kind: Secret
metadata:
  name: telegram-alert
  namespace: default
data:
  telebotToken: YWJjZGVm

---
apiVersion: v1
kind: Service
metadata:
  name: telegram-alert-demo
  namespace: default
spec:
  selector:
    app: telegram-alert-demo
  ports:
    - port: 80
      targetPort: rbasket-http

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: telegram-alert-demo
  namespace: default
spec:
  selector:
    matchLabels:
      app: telegram-alert-demo
  template:
    metadata:
      labels:
        app: telegram-alert-demo
    spec:
      containers:
      - name: rbaskets
        image: darklynx/request-baskets:v1.2.3
        
        resources: &common-resource-usage
          requests:
            cpu: 32m
            memory: 64Mi
          limits:
            cpu: 200m
            memory: 128Mi

        command: [rbaskets, -basket, test]

        ports:
        - name: rbasket-http
          containerPort: 55555

      - name: telegram-alert-on-new-order
        image: shadowlegend/microservices-toolbox:0.1.0

        resources: *common-resource-usage

        envFrom:
        - secretRef:
            name: telegram-alert

        command:
        - bash
        - -c
        - |
          nats sub\
            --raw\
            --server host.docker.internal:24112\
            --durable orders-placed-notifier\
            --stream myapp-cdc\
            myapp-cdc.orders.*.placed |
            while read -r payload
            do
              echo "\$payload"
              read data <<< \$(jq -r 'select(.action == "insert") | tostring' <<< \$payload)
              if [ -z "\${data}" ]; then
                continue
              fi
              cat <<-EOF> msg
          <b>🚨 new order placed</b>
          order id: \$(jq -r .data.id <<< \$data)
          total price (usd): <span class="tg-spoiler">\$(jq -r .data.total_price_in_usd <<< \$data)</span>
          customer loyalty level: \$(jq -r .data.customer_loyalty_level <<< \$data)
          created time: \$(jq -r .data.created_at <<< \$data)
          EOF
              curl -v -XPOST -Hcontent-type:application/json "https://api.telegram.org/\$telebotToken/sendMessage" -d "\$(jo parse_mode=HTML chat_id=-1000000000000 message_thread_id=000 text=@msg)"
            done
EOF
kubectl wait --for=condition=Available=True deployment/telegram-alert-demo --timeout=16m
kubectl wait pod -l app=telegram-alert-demo --for=condition=Ready --timeout=16m
# obtain token can from rbaskets
kubectl logs -l app=telegram-alert-demo | grep 'access token:'
# you can visit localhost:55557/web/test on your browser
kubectl port-forward svc/telegram-alert-demo 55557:80
# send below message for testing and watch for changes
# in rbaskset webui
nats --server localhost:24112 pub myapp-cdc.orders.20690609113.placed $(jo action=insert data=$(jo id="20690609$RANDOM" total_price_in_usd=$(shuf -i2-1000 -n1).$(shuf -i0-99 -n1) customer_loyalty_level=$(awk 'BEGIN { srand(); split("bronze silver gold platinum diamond", r); print r[int(rand() * 5) + 1] }') created_at=$(date -u +'%Y-%m-%dT%H:%M:%SZ')))
```
