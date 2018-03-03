#!/bin/bash

ecr_auth=( aws ecr get-login --region us-east-1 )
$(${ecr_auth[@]} | sed 's/\-e none//')
docker pull 1234567890.dkr.ecr.us-east-1.amazonaws.com/nginx-emr-reverse-proxy:latest
docker stop emr-proxy
docker rm emr-proxy
docker run -d -p 80:80 -p 8080:8080 -p 8088:8088 -p 8188:8188 -p 8890:8890 -p 8888:8888 -p 8889:8889 -p 10002:10002 -p 18080:18080 -p 20888:20888 -p 50070:50070 -v /opt/nginx/vhosts.conf:/etc/nginx/conf.d/vhosts.conf -v /opt/nginx/.htpasswd:/etc/nginx/.htpasswd --restart=unless-stopped --name emr-proxy 1234567890.dkr.ecr.us-east-1.amazonaws.com/nginx-emr-reverse-proxy:latest
