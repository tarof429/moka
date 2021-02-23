# Lazy Sunday

## Introduction

A Kubernetes cluster with 2 nodes and 1 VM running haproxy. All VMs are running in VirtualBox and are provisioned using Vagrant.

## Installation

1. Bring up the machines

    ```
    vagrant up
    ```

2. Confirm the setup

    ```
    vagrant status
    ```

3. Login to each node and run `docker login`. One way to semi-automate this is with the following:

    ```
     vagrant ssh <node> -c "echo <password> | docker login --username <username> --password-stdin"
     ```

3. Download RKE from `https://github.com/rancher/rke/releases`.

4. Bring up the cluster

    ```
    rke up
    ```

## Configuration

As in the video, we're going to manually edit the haproxy.cfg file on the haproxy VM.

1. Login to haproxy

    ```
    vagrant ssh haproxy
    ```
2. Delete everything after global and defaults in /etc/haproxy/haproxy.cfg and paste the contents of haproxy.cfg.

3. Edit haproxy.cfg and replace

    ```
    server kube <worker-node1-ip>:80
    server kube <worker-node2-ip>:80
    ```

    with

    ```
    server kube 172.28.128.11:80
    server kube 172.28.128.12:80
    ```

4. Enable haproxy

    ```
    systemctl enable haproxy
    systemctl start haproxy
    ```

5. In the browser, search for nginx ingress and go to the git repo `https://github.com/nginxinc/kubernetes-ingress`

6. Clone the repository

7. The install instructions are at `https://docs.nginx.com/nginx-ingress-controller/installation`. Select the link that says Installation with Manifests and follow the instructions. You will need to create namespace, service account, 


Note: You MUST make sure cluster.yml states `none` for ingress provider (this is already done for you, but just so you know). Otherwise, the nginx ingress which we install manually will fail to start.

Aftwards, the pods are running.

    ```
    $ kubectl get pod --namespace=nginx-ingress
    NAME                  READY   STATUS    RESTARTS   AGE
    nginx-ingress-gsqn4   1/1     Running   0          9m20s
    nginx-ingress-zgmlr   1/1     Running   0          9m20s
    ```

8. Next, we're going to deploy kubernetes/yamls/ingress-demo/nginx-deploy-main.yaml from `justmeandopensource/kubernetes/yamls/ingress-demo`. 

    ```
    $ kubectl create -f nginx-deploy-main.yaml 
    deployment.apps/nginx-deploy-main created
    ```

9. Next, we're going to expose the deployment as a sevice.

    ```
    kubectl  expose deploy/nginx-deploy-main --port 80
    service/nginx-deploy-main exposed
    ```

10. Next, we need to deploy the ingress resource. Use the ingress-resource-1.yaml in this directory instead of the one from https://github.com/justmeandopensource/kubernetes. The reason is that if you try to deploy the ingress resource from  the other repository, it will result in an error.

11. Next, we configure our hosts `/etc/hosts` file and add an entry for nginx.example.com. As explained in the video, this should point to the IP address of haproxy.

    ```
    172.28.128.13 nginx.example.com
    ```

12. Go to the browser and navigate to `http://nginx.example.com/`. This will actually have a problem if you refresh the browser and haproxy tries to do round-robin load balancing to the next node. To solve this, change the deployment for nginx-deploy-main and increase the number of replicas to 2. 

13. Delete the ingress.

    ```
    kubectl delete ingress ingress-resource-1
    ingress.extensions "ingress-resource-1" deleted
    ```

14. Next, deploy `yamls/ingress-demo/nginx-deploy-blue.yaml` and `yamls/ingress-demo/nginx-deploy-gree.yaml` from `https://github.com/justmeandopensource/kubernetes`. These configuration files use init containers to create an HTML page that tthe nginx deployment will serve.

15. Next, expose these deployments.

    ```
    $ kubectl expose deploy nginx-deploy-blue --port 80
    service/nginx-deploy-blue exposed
    $ kubectl expose deploy nginx-deploy-green --port 80
    service/nginx-deploy-green exposed
    ```

    And if we check services, we'll see two more.

    ```
    $ kubectl get svc
    NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
    kubernetes           ClusterIP   10.43.0.1      <none>        443/TCP   46m
    nginx-deploy-blue    ClusterIP   10.43.189.86   <none>        80/TCP    50s
    nginx-deploy-green   ClusterIP   10.43.149.14   <none>        80/TCP    44s
    nginx-deploy-main    ClusterIP   10.43.95.19    <none>        80/TCP    24m
    ```

16. Next, we need to deploy the ingress resource. Use the ingress-resource-2.yaml in this directory instead of the one from `https://github.com/justmeandopensource/kubernetes`.  

17. Next, edit /etc/hosts and add two more hosts.

    ```
    172.28.128.13 blue.nginx.example.com
    172.28.128.13 green.nginx.example.com
    ```

18. Now you should be able to the browser and go to `http://blue.ngix.example.com` and `http://green.nginx.example.com`. As before, this will have a problem if you refresh the browser and haproxy tries to do round-robin load balancing to the next node. To solve this, change the deployment for nginx-deploy-blue and nginx-deploy-green and increase the number of replicas to 2. 


## Bonus!

Another project located in bonus/hello-python illustrates how we can use nginx ingress to proxy requests to an application that does not use port 80 internally. Just add 

```
172.28.128.13 hello-python.example.com
```

to your hosts file. Then,

```
$ curl http://hello-python.example.com/tree
Happy tree!
```

A look at the services:

```
$ kubectl get svc
NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
hello-python-service   ClusterIP   10.43.195.44   <none>        5000/TCP   2m21s
kubernetes             ClusterIP   10.43.0.1      <none>        443/TCP    29h
nginx-deploy-blue      ClusterIP   10.43.189.86   <none>        80/TCP     28h
nginx-deploy-green     ClusterIP   10.43.149.14   <none>        80/TCP     28h
nginx-deploy-main      ClusterIP   10.43.95.19    <none>        80/TCP     29h
```

## References

https://www.youtube.com/watch?v=chwofyGr80c&t=63s

https://github.com/justmeandopensource/kubernetes
