#!/bin/sh

machine="$1"
username="$2"
password="$3"

vagrant ssh $machine -c "echo $password | docker login -u $username --password-stdin"