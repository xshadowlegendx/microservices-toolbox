FROM alpine:3.22

RUN apk add --no-cache --virtual .tools m4 jo curl unzip jsonnet openssl uuidgen aws-cli postgresql16-client &&\
  ARCH=$(arch | sed 's/aarch64/arm64/; s/x86_64/amd64/;') &&\
  curl -sLo /usr/local/bin/kubectl https://dl.k8s.io/release/v1.34.0/bin/linux/$ARCH/kubectl &&\
  curl -sLo /usr/local/bin/jq https://github.com/jqlang/jq/releases/download/jq-1.8.1/jq-linux-$ARCH &&\
  curl -sLo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.48.1/yq_linux_$ARCH &&\
  chmod +x /usr/local/bin/jq /usr/local/bin/yq &&\
  curl -sLo nats.zip https://github.com/nats-io/natscli/releases/download/v0.3.0/nats-0.3.0-linux-$ARCH.zip &&\
  unzip nats.zip &&\
  mv nats-0.3.0-linux-$ARCH/nats /usr/local/bin/ &&\
  curl -sLo miller.tar.gz https://github.com/johnkerl/miller/releases/download/v6.15.0/miller-6.15.0-linux-$ARCH.tar.gz &&\
  tar -xzf miller.tar.gz && mv miller-6.15.0-linux-$ARCH/mlr /usr/local/bin/ &&\
  rm -rf nats.zip nats-0.3.0-linux-$ARCH miller.tar.gz miller-6.15.0-linux-$ARCH
