#!/bin/sh
openssl req -new -key certs/taro.key -out certs/taro.csr -subj "/C=US/ST=CA/L=San Jose/O=rbac.authorization.k8s.io/OU=Engineering/CN=taro"
