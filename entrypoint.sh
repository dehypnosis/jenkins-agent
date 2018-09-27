#!/usr/bin/env bash

DOCKER_GID=$(stat -c '%g' /var/run/docker.sock) && \
    groupadd -for -g ${DOCKER_GID} docker && \
    usermod -aG docker jenkins

# login to registry using k8s local docker config secret
docker login registry.k8s.strix.kr \
    --username=$(echo $DOCKER_CONFIG | jq -r '.["auths"]["registry.k8s.strix.kr"].username') \
    --password=$(echo $DOCKER_CONFIG | jq -r '.["auths"]["registry.k8s.strix.kr"].password') \
    2> /dev/null

# execute original entrypoint with arguments
jenkins-slave ${@:2}
