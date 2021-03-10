# basic-auth

Basic authentication example

## Preparation

1. Bring up the VMs

```
vagrant up
```

2. Bring up the cluster.

```
rke up
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
$ kubectl get secret admin-auth -o yaml
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

Deploy `nginx-deploy-main.yaml`

```
kubectl apply -f nginx-deploy-main.yaml
```

Deploy `insecure-ingress-resource.yaml`

```
kubectl apply -f insecure-ingress-resource.yaml
```

Test

```
w3m http://insecure.example.com
```

Then deploy `basic-auth-ingress-resource.yaml`

```
kubectl delete -f insecure-ingress-resource.yaml
kubectl apply -f basic-auth-ingress-resource.yaml
```

Test

```
w3m http://basic-auth.example.com
```