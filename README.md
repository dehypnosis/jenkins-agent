# Dockerfile for k8s jenkins-agent
## Includes
- kubectl client
    - A default service account for dev namespace will be mounted by volume on runtime by jenkins k8s pod template.
- docker client:
    - A docker configuration for private registry will be exported as env var `DOCKER_CONFIG` on runtime by jenkins k8s pod template.
    - And `entrypoint.sh` will parse `DOCKER_COFING` and login to private registry.
    - Caveat! container ounts host's `/var/run/docker.sock`.
    
## Contribute
- hard and dangerous test:
    - run `make`
    - start any build job for test