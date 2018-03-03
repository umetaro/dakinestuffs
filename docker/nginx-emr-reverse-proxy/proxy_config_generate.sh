#!/bin/bash
set -x
export VPN_CIDR=<IP ADDRESS HERE>
export REGION=$(curl -s instance-data/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//')

# vhost template generation
function vhost {
  cat << 'EOF' >> /opt/nginx/vhosts.conf
  server {
    listen 80;
    listen 8080;
    listen 8088;
    listen 8188;
    listen 8888;
    listen 8889;
    listen 8890;
    listen 10002;
    listen 18080;
    listen 20888;
    listen 50070;
    server_name DNSNAME.company.com;

    location / {
      satisfy all;
      allow VPN_CIDR/32;
      deny  all;

      auth_basic "Authorized Users";
      auth_basic_user_file /etc/nginx/.htpasswd;
      resolver 10.OCTET2.0.2;
      proxy_http_version 1.1;
      proxy_read_timeout 1800s;
      proxy_set_header "Access-Control-Allow-Origin" $http_origin;
      proxy_set_header Connection upgrade;
      proxy_set_header Host $host:$proxy_port;
      proxy_set_header Referer $http_referer;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header X-Forwarded-For $remote_addr;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_pass  http://UPSTREAM_IP:$server_port;
      proxy_redirect ~*http://ip-10-[^:]+:(\d+)(/.+)$ http://DNSNAME.company.com:$1$2;
      sub_filter_types *;
      sub_filter_once off;
      sub_filter DNSHOST.ec2.internal 'DNSNAME.company.com';
      sub_filter DNSHOST.company.com 'DNSNAME.company.com';
    }
  }
EOF
}

# install htpasswd
rpm -qa | grep httpd-tools && echo "htpasswd installed" || sudo yum install -y httpd-tools

# get password value
HTPASS="$(aws ssm get-parameter --with-decryption --name /vault/etlproxy/${ENV}/hadoop --query 'Parameter.Value' --region ${REGION} --output text)"

# write value to htpasswd file
sudo htpasswd -bc /opt/nginx/.htpasswd hadoop "${HTPASS}"

# remove previous vhost config
[ -f /opt/nginx/vhosts.conf ] && rm -f /opt/nginx/vhosts.conf

# loop of active clusters in env
for i in $(aws etl list-clusters --active --region ${REGION} --output text | grep -E "${ENV}-[0-9]{4}-etl" | awk '{ print $2 }'); do
  export MASTERIP=$(aws etl list-instances --cluster-id ${i} --instance-group-types MASTER --query 'Instances[].PrivateIpAddress' --region ${REGION} --output text)
  export AZ=$(aws etl describe-cluster --cluster-id ${i} --query 'Cluster.Name' --region ${REGION} --output text | awk -F- '{ print $4 }')

# generate IP octet values
  IPARRAY=${MASTERIP}
  export OCTET1=${IPARRAY%%.*}
  IPARRAY=${IPARRAY#*.*}
  export OCTET2=${IPARRAY%%.*}
  IPARRAY=${IPARRAY#*.*}
  export OCTET3=${IPARRAY%%.*}
  IPARRAY=${IPARRAY#*.*}
  export OCTET4=${IPARRAY%%.*}
  export DNSHOST="ip-10-${OCTET2}-${OCTET3}-${OCTET4}"
  
  # grab 2nd octet for vpc NS IP determination 
  case ${OCTET2} in
    20)   export ENV="stg"
          ;;
    30)   export ENV="prd"
          ;;
    100)  export ENV="mgt"
          ;;
  esac
  [ ! -d /opt/nginx ] && sudo mkdir -p /opt/nginx
  [ ! -O /opt/nginx ] && sudo chown ec2-user:ec2-user /opt/nginx
  
  # export to config file
  vhost
  
  # sub values
  sed -i "s/DNSHOST/${DNSHOST}/g" /opt/nginx/vhosts.conf 
  sed -i "s/VPN_CIDR/${VPN_CIDR}/g" /opt/nginx/vhosts.conf
  sed -i "s/OCTET2/${OCTET2}/g" /opt/nginx/vhosts.conf
  sed -i "s/UPSTREAM_IP/${MASTERIP}/g" /opt/nginx/vhosts.conf
  sed -i "s/DNSNAME/${ENV}-etl-${AZ}/g" /opt/nginx/vhosts.conf
done

