# Introduction

Docker image for Ignite

## Usage

First, you must build a docker image and push it to docker regitry. 

```
REV=$(git rev-parse --short HEAD)
docker build --rm -t tarof429/centos7-ignite .
docker push tarof429/centos7-ignite
```

Then use `ignite` to import the image.

```
ignite image import tarof429/centos7-ignite
```

Afterwards you should be able to start the VM.

```
sudo ignite run tarof429/centos7-ignite --name my-vm --cpus 2  --memory 1GB --size 6GB
INFO[0000] Created VM with ID "85932db89c3fb1e8" and name "my-vm" 
```



## References

https://github.com/weaveworks/ignite/blob/master/docs/usage.md