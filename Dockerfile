# ref: https://github.com/jenkinsci/docker-jnlp-slave/blob/master/Dockerfile
FROM jenkins/jnlp-slave:alpine

USER root

# install docker client
# * should mount /var/run/docker.sock:/var/run/docker.sock to use docker
RUN apk add --update docker

# install kubectl
# * namespace's default service account will be mount automatically when launch in k8s cluster
ENV KUBE_LATEST_VERSION="v1.11.3"
RUN apk add --update ca-certificates \
    && apk add --update -t deps curl \
    && curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && apk del --purge deps

# json parsing tool
RUN apk add --update jq

# remove deps and apk cache
RUN rm /var/cache/apk/*

# return to jenkins
USER jenkins

# change entry script
ADD entrypoint.sh /
ENTRYPOINT /entrypoint.sh