FROM alpine:3.23

RUN apk add --no-cache --virtual .tools m4 jo bash curl unzip jsonnet openssl uuidgen aws-cli iso-codes imagemagick imagemagick-jxl imagemagick-heic &&\
  ARCH=$(arch | sed 's/aarch64/arm64/; s/x86_64/amd64/;') &&\
  curl -sLo /usr/local/bin/kubectl https://dl.k8s.io/release/v1.34.0/bin/linux/$ARCH/kubectl &&\
  curl -sLo /usr/local/bin/jq https://github.com/jqlang/jq/releases/download/jq-1.8.1/jq-linux-$ARCH &&\
  curl -sLo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.48.1/yq_linux_$ARCH &&\
  curl -sLo nats.zip https://github.com/nats-io/natscli/releases/download/v0.3.0/nats-0.3.0-linux-$ARCH.zip &&\
  unzip nats.zip &&\
  mv nats-0.3.0-linux-$ARCH/nats /usr/local/bin/ &&\
  curl -sLo miller.tar.gz https://github.com/johnkerl/miller/releases/download/v6.15.0/miller-6.15.0-linux-$ARCH.tar.gz &&\
  tar -xzf miller.tar.gz && mv miller-6.15.0-linux-$ARCH/mlr /usr/local/bin/ &&\
  curl -sLo usql.tar.bz2 https://github.com/xo/usql/releases/download/v0.20.0/usql_static-0.20.0-linux-$ARCH.tar.bz2 &&\
  tar -xjf usql.tar.bz2 &&\
  mv usql_static /usr/local/bin/usql &&\
  curl -sLo /usr/local/bin/gomplate https://github.com/hairyhenderson/gomplate/releases/download/v4.3.3/gomplate_linux-$ARCH &&\
  chmod +x /usr/local/bin/jq /usr/local/bin/yq /usr/local/bin/kubectl /usr/local/bin/gomplate &&\
  rm -rf nats.zip nats-0.3.0-linux-$ARCH miller.tar.gz miller-6.15.0-linux-$ARCH usql.tar.bz2
