all:
	docker build . -t registry.k8s.strix.kr/jenkins-agent:latest
	docker push registry.k8s.strix.kr/jenkins-agent:latest