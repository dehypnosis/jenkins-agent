#!/usr/bin/env bash

# copy mounted docker credential and login
mkdir /root/.docker && cat /root/docker-secret/.dockerconfigjson > /root/.docker/config.json
docker login registry.k8s.strix.kr

# execute original entrypoint with arguments
jenkins-slave ${@:2}
