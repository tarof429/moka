# Docker registry

## Introduction

In  this example, our deployments took an existing nginx images and modified the command line to produce different behaviors. In this example, we will create a docker image, push that to a docker registry which we will set up, and create a deployment that uses those images. This example is based on the video in the link below. The yamls we use are from https://github.com/justmeandopensource/docker.

## Start a basic docker registry

1. Copy 01-plain-html.yaml to docker-compose.yaml and start it. This will use a docker volume.

    ```
    cp 01-plain-html.yaml docker-compose.yaml
    docker-compose up -d
    ```

2. Next, let's go back to the hello-python project from `lazy_sunday` and push it to our docker registry. Assuming we have already built the image locally:

    ```
    docker tag hello-python:latest localhost:5000/hello-python:latest
    docker push localhost:5000/hello-python:latest
    ```

This should work. Pusing docker images to a docker registry on the same machine is easy.

3. Let's confirm by sending a request to the registry.

    ```
    $ curl -X GET http://localhost:5000/v2/_catalog
    {"repositories":["hello-python"]}
    ```

4. Great! Next, let's confirm that we can pull the image. 

    ```
    docker rmi localhost:5000/hello-python:latest
    docker pull localhost:5000/hello-python:latest
    latest: Pulling from hello-python
    Digest: sha256:953b83345abb916644c97e4c48b34ef34d2e1f8e9e5e1c2da3470dec4a028718
    Status: Downloaded newer image for localhost:5000/hello-python:latest
    localhost:5000/hello-python:latest
    ```

5. Next problem is pulling the image from the nodes. First lets tag the image with an IP that can be resolved by the nodes.

    ```
     docker tag hello-python:latest 192.168.10.102:5000/hello-python:latest
    ```


6. But if you try to push this image to the registry, it will fail.

    ```
    docker push 192.168.10.102:5000/hello-python:latest
The push refers to repository [192.168.10.102:5000/hello-python]
Get "https://192.168.10.102:5000/v2/": http: server gave HTTP response to HTTPS client
    ```

7. Let's fix that. Add this configuration to /etc/docker/daemon.json to each of the worker nodes. Here, `ip` is the IP where the docker registry is running and `port` is the port that it listens to.

    ```
    {
        "insecure-registries": ["<ip>:<port>"]
    }
    ```

    and restart the docker service. 

    ```
    sudo systemctl restart docker
    ``

8. Now pull again.

    ```
    $ docker push 192.168.10.102:5000/hello-python:latest
    The push refers to repository [192.168.10.102:5000/hello-python]
    33a7feddb695: Layer already exists 
    bd5a2c578032: Layer already exists 
    f432dd2617f6: Layer already exists 
    db73a745eb63: Layer already exists 
    57f52abfddf1: Layer already exists 
    621a53e1da0d: Layer already exists 
    2317ed5b21e3: Layer already exists 
    cb381a32b229: Layer already exists 
    latest: digest: sha256:953b83345abb916644c97e4c48b34ef34d2e1f8e9e5e1c2da3470dec4a028718 size: 1996
    ```

## Start a Secure Registry

1. Create a certs directory

    ```
    mkdir certs
    ```

2. Create a file called openssl.conf with the following content as a template.

    ```
    [ req ]
    distinguished_name = req_distinguished_name
    x509_extensions     = req_ext
    default_md         = sha256
    prompt             = no
    encrypt_key        = no

    [ req_distinguished_name ]
    countryName            = "GB"
    localityName           = "London"
    organizationName       = "Just Me and Opensource"
    organizationalUnitName = "YouTube"
    commonName             = "<Docker Server IP>"
    emailAddress           = "test@example.com"

    [ req_ext ]
    subjectAltName = @alt_names

    [alt_names]
    DNS = "<Docker Server IP>"
    ```

3. Generate the certificate and private key

    ```
    openssl req \
    -x509 -newkey rsa:4096 -days 365 -config openssl.conf \
    -keyout certs/domain.key -out certs/domain.crt
    ```
4. To verify the certificate.

    ```
    openssl x509 -text -noout -in certs/domain.crt
    ```

5. Copy `02-with-TLS.yaml` to docker-compose.yaml and run docker-compose up.

6. You should be able to push the docker image.



## References

https://www.youtube.com/watch?v=r15S2tBevoE