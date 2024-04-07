.POSIX:
.SILENT:

.PHONY: all $(MAKECMDGOALS)

JENKINS_SERVER_REGISTRY := docker.io/jenkins/jenkins
JENKINS_SERVER_TAG := 2.452-jdk17

JENKINS_AGENT_REGISTRY := docker.io/jenkins/inbound-agent
JENKINS_AGENT_TAG := 3206.vb_15dcf73f6a_9-9-alpine3.19-jdk17

DOCKER_DIND_REGISTRY := docker.io/library/docker
DOCKER_DIND_TAG := 25.0.5-dind-alpine3.19

.build-agent/%:
	docker build \
		--build-arg JENKINS_REGISTRY="$(JENKINS_AGENT_REGISTRY)" \
		--build-arg JENKINS_TAG="$(JENKINS_AGENT_TAG)" \
		--tag localhost/jenkins-agent-$* \
		--file agents/Dockerfile.$* \
		.

.start-agent/%:
	docker run -d --rm --init \
		--name jenkins-agent-$* \
		--network jenkins \
		--env DOCKER_HOST=tcp://docker:2376 \
		--env DOCKER_CERT_PATH=/certs/client \
		--env DOCKER_TLS_VERIFY=1 \
		--env JENKINS_URL=http://jenkins-server:8080 \
		--env JENKINS_AGENT_NAME=agent01 \
		--env JENKINS_AGENT_WORKDIR=/home/jenkins/agent \
		--env JENKINS_SECRET=$(shell cat secrets/jenkins-agent-$*) \
		--volume jenkins-docker-certs:/certs/client:ro \
		localhost/jenkins-agent-$*

build-agents: .build-agent/docker .build-agent/maven .build-agent/node
build-agents:

start-server:
	-docker network create jenkins
	docker run -d --rm --init \
		--name jenkins-docker \
		--network jenkins \
		--network-alias docker \
		--privileged \
		--env DOCKER_TLS_CERTDIR=/certs \
		--volume jenkins-data:/var/jenkins_home \
		--volume jenkins-docker-certs:/certs/client \
		--publish 2376:2376 \
		--publish 80:80 \
		$(DOCKER_DIND_REGISTRY):$(DOCKER_DIND_TAG)
	docker run -d --rm --init \
		--name jenkins-server \
		--network jenkins \
		--env DOCKER_HOST=tcp://docker:2376 \
		--env DOCKER_CERT_PATH=/certs/client \
		--env DOCKER_TLS_VERIFY=1 \
		--volume jenkins-data:/var/jenkins_home \
		--volume jenkins-docker-certs:/certs/client:ro \
		--publish 8080:8080 \
		--publish 50000:50000 \
		$(JENKINS_SERVER_REGISTRY):$(JENKINS_SERVER_TAG)

start-agents: .start-agent/docker .start-agent/maven .start-agent/node
start-agents:

password:
	docker exec jenkins-server \
		cat /var/jenkins_home/secrets/initialAdminPassword
	echo ""

stop:
	-docker stop jenkins-agent-docker
	-docker stop jenkins-agent-maven
	-docker stop jenkins-agent-node
	-docker stop jenkins-docker
	-docker stop jenkins-server
	-docker network rm jenkins

clean: stop
clean:
	-docker volume rm jenkins-data
	-docker volume rm jenkins-docker-certs
