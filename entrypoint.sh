#!/usr/bin/env bash

# copy mounted docker credential and login
mkdir /root/.docker && cat /root/docker-secret/.dockerconfigjson > /root/.docker/config.json
docker login registry.k8s.strix.kr


# Running docker -v /root:/some/path .., mounts docker host(k8s node)'s /root not the current jenkins agent's /root.
# To solve DinD volume mount problem, should point the k8s node's emptyDir path which bound to current jenkins agent's home.
# For example, when jenkins home ($HOME) is /root,
# replace [/root]/workspace/[job-id] to [/var/lib/kubelet/pods/[current-pod-uid]/volumes/kubernetes.io~empty-dir/workspace-volume/]/workspace/[job-id]

export DOCKER_HOST_HOME=/var/lib/kubelet/pods/`kubectl get pod $HOSTNAME -o 'jsonpath={.metadata.uid}'`/volumes/kubernetes.io~empty-dir/workspace-volume

echo -e "Current jenkins agent's bound docker host path is: \$DOCKER_HOST_HOME=$DOCKER_HOST_HOME\nUse this path when docker volume mounting, for example \${PWD/\$HOME/\$DOCKER_HOST_HOME} can be used to replace \$PWD variable"

# execute original entrypoint with arguments
jenkins-slave ${@:2}
