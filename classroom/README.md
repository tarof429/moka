# Classroom

In this example, there are multiple students in the classroom. Each student has full access to their own namespace in the cluster but not to others. The teacher, on the other hand, has full access to all namespaces.

## Docker registry

First let's setup a docker registry with SSL. 

1. cd docker-registry

2. Generate the certificate and private key

    ```
    openssl req \
    -x509 -newkey rsa:4096 -days 365 -config openssl.conf \
    -keyout certs/domain.key -out certs/domain.crt
    ```

3. Start the registry

    ```
    docker-compose up

## Ignite VM

1. Build the docker image and push it to our docker registry

    ```
    cd centos7-ignite
    docker build --rm -t 192.168.10.102:5000/centos7-ignite:latest .
    docker push 192.168.10.102:5000/centos7-ignite:latest
    ```

2. Start ignited, if it's not already started.

    ```
    # systemctl start ignited
    # systemctl status ignited
    ```

3. Import the image, making sure you specify `docker` as the runtime (using containerd appears to be possible, but this may be left as an exercise. See https://github.com/containerd/containerd/issues/3847)

    ```
    sudo ignite image import 192.168.10.102:5000/centos7-ignite:latest --runtime docker
    INFO[0000] Created image with ID "4c29beaec7daa08f" and name "192.168.10.102:5000/centos7-ignite:latest" 
    ```

4. Start kubemaster

    ```
    sudo ignite run 192.168.10.102:5000/centos7-ignite --name kubemaster --ignite-config ignite-config.yaml 
    INFO[0000] Created VM with ID "2807bc2b1c43a020" and name "kubemaster" 
    INFO[0001] Pulling image "weaveworks/ignite:v0.8.0"...  
    INFO[0010] Networking is handled by "cni"               
    INFO[0010] Started Firecracker VM "2807bc2b1c43a020" in a container with ID "0888a3c78fc36e5f15830dd61a2b4ff87e407a0a9da70083968a6c73bac9d592"
    ```

5. Start kubenode01

    ```
    sudo ignite run 192.168.10.102:5000/centos7-ignite --name kubenode01 --ignite-config ignite-config.yaml 
    INFO[0000] Created VM with ID "04f7328a8daab6c3" and name "kubenode01" 
    INFO[0001] Networking is handled by "cni"               
    INFO[0001] Started Firecracker VM "04f7328a8daab6c3" in a container with ID "fe0bc5227ae26b4547aa762ba7e6ca04deeedfac5ba27601c4e910dcaed0ce5d" 
    ```


6. List VMs

    ```
    $ sudo ignite vm
    VM ID			IMAGE						KERNEL					SIZE	CPUS	MEMORY	CREATED	STATUS	IPS		PORTS	NAME
    2c97687ebfcdd0fe	192.168.10.102:5000/centos7-ignite:latest	weaveworks/ignite-kernel:4.19.125	3.0 GB	4	4.0 GB	13s ago	Up 13s	10.61.0.24		kubemaster
    56f484446ca1a791	192.168.10.102:5000/centos7-ignite:latest	weaveworks/ignite-kernel:4.19.125	3.0 GB	4	4.0 GB	8s ago	Up 8s	10.61.0.25		kubenode01
    ```

## Configure kubemaster

```
ssh root@10.50.21.4
swapoff -a
curl https://releases.rancher.com/install-docker/19.03.sh | sh
useradd cluster-admin
passwd cluster-admin (secret)
usermod -aG docker cluster-admin
sysctl net.bridge.bridge-nf-call-iptables=1
sysctl net.bridge.bridge-nf-call-ip6tables=1
```

Logout, log back in to make sure root is in the docker group, and login to dockerhub.


7. Copy SSH public key to both of the nodes.

    ```
    ssh-copy-id cluster-admin@10.61.0.24 (password is secret)
    ssh-copy-id cluster-admin@10.61.0.25 (password is secret)
    ```

## Configure kubenode01

```
ssh cluster-admin@10.61.0.25
yum -y install initscripts
curl https://releases.rancher.com/install-docker/19.03.sh | sh
passwd cluster-admin (secret)
usermod -aG docker cluster-admin
sysctl net.bridge.bridge-nf-call-iptables=1
sysctl net.bridge.bridge-nf-call-ip6tables=1
```

Logout, log back in to make sure root is in the docker group, and login to dockerhub.

#  Enable docker remote API access

Edit /usr/lib/systemd/system/docker.service so that it says `ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:4243 --containerd=/run/containerd/containerd.sock`. 


```
# systemctl daemon-reload
# systemctl restart docker
```