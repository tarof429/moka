# basic-auth

Basic authentication example

## Preparation

This project uses `https://github.com/tarof429/aruku` to help with provisioning of the nodes.

1. Clone `https://github.com/tarof429/aruku` and run `make && go install`. This will install `aruku` in $GOPATH/bin.

2. Start aruku

  ```
  aruku load .
  ```

1. Bring up the VM sby selecting `Start VMs` in the aruku menu.

2. If this is the first time, select `Login to hub.docker.com`.

3. Then select `Bring up the cluster`.


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

## Shutting down the cluster

Run `aruku` and select `Shutdown the cluster`.
