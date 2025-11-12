# Microservices Toolbox

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
- `jo`
- `m4`
- `openssl`
- `uuidgen`
- `curl`
- `unzip`

## Getting started
```bash
docker run --rm -it shadowlegend/microservices-toolbox:0.0.1 jo hello=world
```
