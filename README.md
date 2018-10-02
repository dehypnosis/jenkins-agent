# Dockerfile for k8s jenkins-agent
## Features
- Run as `root`
- Ready for `kubectl` client:
    - A `jenkins-agent` service account for dev namespace will be mounted as volume on runtime by jenkins k8s pod template.
- Ready for `docker` client:
    - A docker credential `local-docker-registry-secret` for private registry will be mounted as volume at `/root/docker-secret/.dockerconfigjson` on runtime by jenkins k8s pod template.
    - And `entrypoint.sh` will copy it to proper path and will login to private registry.
    - Caveat: The agent container dangerously mounts host's `/var/run/docker.sock` rather than a socket toward self hosted docker engine for the performance's sake.
    
## Contribute
- Update `Dockerfile` and run `make`
- Start building for any test project
- Run blocking command like `sleep 100000` in any stage of Jenkinsfile would be helpful to debug the agent container.

## Jenkins kubernetes plugin configuration
Unlisted fields can be empty. Visit https://deploy.k8s.strix.kr for latest configuration.
```
# Cloud-Kubernetes
Name                    kubernetes
Kubernetes Namespace    default
Jenkins URL             http://jenkins.default:8080
Jenkins tunnel          jenkins-agent.default:50000
Images
    Name                jenkins-agent
    Namespace           dev
    Labels              jenkins
    Containers	
        Name                    jnlp
        Docker image	        registry.k8s.strix.kr/jenkins-agent:latest
        Always pull image       (checked)
        Working directory       /root
        Command to run          (empty)
        Arguments ..	        ${computer.jnlpmac} ${computer.name}
        Allocate pseudo-TTY     (checked)
    Volumes	
        Host Path Volume
            Host path           /var/run/docker.sock
            Mount path	        /var/run/docker.sock
        Secret Volume
            Secret name	        local-docker-registry-secret
            Mount path	        /root/docker-secret
    ...
    	
 	Service Account	    jenkins-agent
        

```

## Solve DinD volume mounting problem

Current agent image mounts docker host's (k8s node) /var/run/docker.sock, So volume mounting needs tricky pattern.

For example, below command will not mount `SCM tree's ./src dir` but `k8s node's $PWD/src` dir.
```
docker run -v ./src:/my-images-some-directory my-image do-something
```

To solve this problem, `./entrypoint.sh` export's the variable `$DOCKER_HOST_HOME` which is real host path of jenkins agent's `$HOME` (/root).
So, This can be use when mounting volume in DinD situation.

For example, below command will work!
```
docker -run -v ${PWD/$HOME/$DOCKER_HOST_HOME}/src:/my-images-some-directory my-image do-something
```
