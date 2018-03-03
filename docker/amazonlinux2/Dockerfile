FROM amazonlinux:2

ARG REMOTING_VERSION=3.15

ENV HOME=/home/jenkins
    
RUN  groupadd -r -g 10000 jenkins \
  && adduser -m -r -d ${HOME} -u 10000 -g jenkins jenkins \
  && yum -y install aws-cli git java-1.8.0-openjdk openssh-clients tar unzip wget \
  && yum clean all \
  && rm -rf /var/cache/yum \
  && curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/main/remoting/${REMOTING_VERSION}/remoting-${REMOTING_VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar \
  && mkdir -p ${HOME}/.docker \
  && echo '{ "credsStore": "ecr-login" }' > ${HOME}/.docker/config.json \
  && mkdir -p ${HOME}/.m2 \
  && chown -R jenkins:jenkins ${HOME}

COPY docker-credential-ecr-login /usr/local/bin/docker-credential-ecr-login
COPY jenkins-slave /usr/local/bin/jenkins-slave

USER jenkins

ENTRYPOINT ["jenkins-slave", "-workDir", "/home/jenkins/workspace"]
