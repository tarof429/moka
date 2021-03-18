#!/bin/sh

machine="$1"
host="$2"
username="$3"
password="$4"

ssh -i .vagrant/machines/${machine}/virtualbox/private_key rke@${host} "echo ${password} | docker login -u $username --password-stdin"
#vagrant ssh $machine -c "echo $password | docker login -u $username --password-stdin"