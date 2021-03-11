# Introduction

This is a simple application illustration configuration from load-balancer to nginx-ingress to service.

## Building

```
docker build -f docker/Dockerfile -t <account>/hello-python:latest .
docker push <account>/hello-pthon:latest
```

## Deploying

```
kubectl apply -f kubernetes
```