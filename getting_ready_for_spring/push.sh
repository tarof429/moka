#!/bin/sh

docker tag hello-python:latest localhost:5000/hello-python:latest
docker push localhost:5000/hello-python:latest
