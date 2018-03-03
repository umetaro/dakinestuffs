#!/bin/bash

ecr_auth=( aws ecr get-login --region us-east-1 )
$(${ecr_auth[@]} | sed 's/\-e none//')
docker pull 1234567890.dkr.ecr.us-east-1.amazonaws.com/jenkins-docker:latest
docker stop jenkins && docker rm jenkins
/usr/bin/docker run -d --env JAVA_OPTS=-Dhudson.model.LoadStatistics.clock=1000 --name jenkins -p 5000:5000 -p 8080:8080 -v /mnt/jenker/jenkins_home:/var/jenkins_home -v /mnt/jenker/backups:/var/jenkins_home/backups -v /var/lib/jenkins/monitoring:/var/jenkins_home/monitoring -v /var/lib/jenkins/nodes:/var/jenkins_home/nodes -v /var/lib/jenkins/war:/var/jenkins_home/war -v /var/lib/jenkins/workspace:/var/jenkins_home/workspace -v /var/log/jenkins:/var/jenkins_home/logs -v /var/run/docker.sock:/var/run/docker.sock --restart=unless-stopped 1234567890.dkr.ecr.us-east-1.amazonaws.com/jenkins-docker:latest
docker logs -f jenkins &
