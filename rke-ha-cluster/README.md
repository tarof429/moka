# RKE Cluster in HA Mode

Steps:

1. Install required packages

```
ansible-playbook -i inventory.ini install_required_packages.yml
```

2. Create rke user

```
ansible-playbook -i inventory.ini create_rke_user.yml
```

3. Enable required kernel modules

```
ansible-playbook -i inventory.ini enable_required_modules.yml
```

4. Disable swap and Modify sysctl entries

```
ansible-playbook -i inventory.ini disable_swap.yml
```

5. Install docker

```
ansible-playbook -i inventory.ini install_docker.yml
```

6. Login to dockerhub by running:


```
aruku load .
```

and selecting Login to hub.docker.com.

## Start the Cluster

```
vagrant up
rke up
```

## Deploy the app

```
cp kube_config_cluter.yml ~/.kube/config
kubectl apply -f k8s
```

This should create two pods, one on each worker node.

## Configure HA Proxy

Manually edit the haproxy.cfg file on the haproxy VM.

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

## Configure hosts file

Edit /etc/hosts to map the hostname to HA Proxy

```
172.28.128.15 insecure.example.com
```

## Summary

We have created a highly-available k8s cluster that is able to withstand node failure. It should be able to serve the sample application with only 1 master and 1 worker node running. 

## References

https://computingforgeeks.com/install-kubernetes-production-cluster-using-rancher-rke/

https://www.serverlab.ca/tutorials/linux/network-services/how-to-configure-haproxy-health-checks/