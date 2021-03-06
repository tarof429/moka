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
[taro@zaxman oauth-external-auth]$ kubectl get secret admin-auth -o yaml
apiVersion: v1
data:
  auth: YWRtaW46JGFwcjEkUHlMMERIbEQkRTJUSEVaYUU3a0xLNmQubzhIWFhCMAo=
kind: Secret
metadata:
  creationTimestamp: "2021-03-05T18:52:33Z"
  name: admin-auth
  namespace: default
  resourceVersion: "17822"
  selfLink: /api/v1/namespaces/default/secrets/admin-auth
  uid: f727619d-7334-4606-9ac0-09fde00f6e3f
type: Opaque
```

## Deploying external-oauth-resource



https://kubernetes.github.io/ingress-nginx/examples/auth/basic/

## Ingress resources

- insecure-ingress-resource.yaml demonstrates how to expose a service without any security

- 

60a9f99a74e0cd6946ed5792988fcfc3a5bc0bdd client secret