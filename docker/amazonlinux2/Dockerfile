FROM 502718739766.dkr.ecr.us-east-1.amazonaws.com/amazonlinux2:base

ARG REMOTING_VERSION=3.17

ENV HOME=/home/jenkins

COPY docker-credential-ecr-login /usr/local/bin/docker-credential-ecr-login
COPY jenkins-slave /usr/local/bin/jenkins-slave
    
RUN yum -y install aws-cli git java-1.8.0-openjdk openssh-clients shadow-utils tar unzip wget \
  && amazon-linux-extras install python3 \
  && yum clean all \
  && groupadd -r -g 10000 jenkins \
  && adduser -m -r -d ${HOME} -u 10000 -g jenkins jenkins \
  && rm -rf /var/cache/yum \
  && curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/main/remoting/${REMOTING_VERSION}/remoting-${REMOTING_VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar \
  && mkdir -p ${HOME}/.docker \
  && echo '{"credsStore":"ecr-login","auths":{"502718739766.dkr.ecr.us-east-1.amazonaws.com":{}}}' > ${HOME}/.docker/config.json \
  && mkdir -p ${HOME}/.m2 \
  && chown -R jenkins:jenkins ${HOME} \
  && chmod -R +x /usr/local/bin

CMD ["/bin/bash"]
