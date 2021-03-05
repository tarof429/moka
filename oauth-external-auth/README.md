# oauth-external-auth

Oauth authentication with github

## Preparation

1. Bring up the VMs

```
vagrant up
```

2. Login to each VM and set dockerhub credentials.

## Deploying basic-auth-ingress-resource

First create a secret.

```
$ htpasswd -c auth admin
New password: <secret>
New password:
Re-type new password:
Adding password for user admin
```

```
$ kubectl create secret generic admin-auth --from-file=auth
secret "admin-auth" created
```

```
```

https://kubernetes.github.io/ingress-nginx/examples/auth/basic/

## Ingress resources

- insecure-ingress-resource.yaml demonstrates how to expose a service without any security

- 