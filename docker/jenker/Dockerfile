FROM nimmis/alpine-java:openjdk-8-jdk

ARG JENKINS_VERSION=2.102
ENV user=jenkins \
  DOCKER_GID=497 \
  GROUP_ID=495 \
  USER_ID=497 \
  JENKINS_HOME=/var/jenkins_home \
  JENKINS_SLAVE_AGENT_PORT=5000
ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

RUN addgroup -S -g $GROUP_ID jenkins \
  && addgroup -S -g $DOCKER_GID docker \
  && adduser -S -u $USER_ID -h $JENKINS_HOME -G jenkins -s /bin/bash jenkins \
  && apk add --update --no-cache bash ca-certificates coreutils curl fontconfig git groff less openssh python py-pip py-setuptools rsync shadow tini ttf-dejavu \
  && curl -fsSL https://get.docker.com/builds/Linux/x86_64/docker-17.05.0-ce.tgz | tar --strip-components=1 -xz -C /usr/local/bin docker/docker \
  && pip --no-cache-dir install awscli \
  && usermod -a -G docker jenkins \
  && mkdir -p /usr/share/jenkins/ref/init.groovy.d \
  && chown -R $USER_ID:$GROUP_ID $JENKINS_HOME /usr/share/jenkins/ref \
  && curl -fsSL https://updates.jenkins-ci.org/download/war/$JENKINS_VERSION/jenkins.war -o /usr/share/jenkins/jenkins.war \
  && apk del py-pip py-setuptools \
  && rm -rf /var/cache/apk/*


WORKDIR /opt/
ENV     GROOVY_HOME /opt/groovy/
ENV     PATH ${PATH}:${GROOVY_HOME}/bin
ENV     GROOVY_VERSION 2.4.9

RUN     apk --update add curl unzip && \
        curl -sLo /opt/groovy.zip https://bintray.com/artifact/download/groovy/maven/apache-groovy-binary-${GROOVY_VERSION}.zip && \
        unzip /opt/groovy.zip && \
        rm -f /opt/groovy.zip && \
        ln -s /opt/groovy-${GROOVY_VERSION} /opt/groovy && \
        echo "ServerAliveInterval 120" >> /etc/ssh/ssh_config

RUN set -ex \
  && sed -i "s|#!/bin/sh|#!/bin/bash|" /opt/groovy/bin/grape \
  && sed -i "s|#!/bin/sh|#!/bin/bash|" /opt/groovy/bin/groovy \
  && sed -i "s|#!/bin/sh|#!/bin/bash|" /opt/groovy/bin/groovyc \
  && sed -i "s|#!/bin/sh|#!/bin/bash|" /opt/groovy/bin/groovyConsole \
  && sed -i "s|#!/bin/sh|#!/bin/bash|" /opt/groovy/bin/groovydoc \
  && sed -i "s|#!/bin/sh|#!/bin/bash|" /opt/groovy/bin/groovysh \
  && sed -i "s|#!/bin/sh|#!/bin/bash|" /opt/groovy/bin/java2groovy

# could use ADD but this one does not check Last-Modified header neither does it allow to control checksum
# see https://github.com/docker/docker/issues/8331
COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy

# for main web interface:
EXPOSE 8080
EXPOSE $JENKINS_SLAVE_AGENT_PORT

COPY jenkins-support /usr/local/bin/jenkins-support
COPY jenkins.sh /usr/local/bin/jenkins.sh
COPY docker-credential-ecr-login /usr/local/bin/docker-credential-ecr-login
USER jenkins:docker
WORKDIR /var/jenkins_home
RUN mkdir $JENKINS_HOME/.docker
COPY config.json /tmp/config.json

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]

# moot while jenkins_home is a persistent storage mount
# from a derived Dockerfile, can use `RUN plugins.sh active.txt` to setup /usr/share/jenkins/ref/plugins from a support bundle
COPY plugins.sh /usr/local/bin/plugins.sh
COPY install-plugins.sh /usr/local/bin/install-plugins.sh
COPY hudson.plugins.groovy.Groovy.xml /usr/share/jenkins/ref/hudson.plugins.groovy.Groovy.xml
#COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
#RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

# disable install plugins wizard
#RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
