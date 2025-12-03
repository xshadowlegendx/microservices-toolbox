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
