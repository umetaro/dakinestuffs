#!/usr/bin/env bash
#
#  sets up a user's local machine for remote access to cloud environment
#

# set these
HOSTNAME="YOUR.BASTION-JUMP-HOSTNAME.HERE"
BASEDOMAIN="INSTANCE-BASE.DOMAIN"


# bold text
bold=$(tput bold)
normal=$(tput sgr0)

echo "${bold}Username for HOSTNAME${normal}"
echo "Hit Enter to use default"
echo ""
read -p "username ($(whoami)): " USERNAME
USER="${USERNAME:-$(whoami)}"

echo ""
echo "${bold}Enter the number corresponding to your ssh PRIVATE (not pub) key.${normal}"
PS3="
keyname: "
echo ""
select KEYNAME in ~/.ssh/*;
do
  case "$KEYNAME" in
    *) echo ""
       echo "You chose $KEYNAME (${REPLY})"
       [[ -f ${KEYNAME} ]] || { echo "key does not exist!"; exit 1; }
       export KEY="$(echo ${KEYNAME} | awk -F/ '{ print $NF }')"
       break
       ;;
  esac
done
echo ""
echo "creating ssh control directory..."
mkdir -p ~/.ssh/control && chmod 700 ~/.ssh/control
echo ""

echo "saving old config to ~/.ssh/config if it exists..."
if [[ -f ~/.ssh/config ]]; then
  cp ~/.ssh/config ~/.ssh/config.old && chmod 600 ~/.ssh/config
fi
echo ""

echo "creating new ssh config file..."
cat << EOF > ~/.ssh/config
AddKeysToAgent yes
UseKeychain yes
ForwardAgent yes

# Use a shared channel for all sessions to the same host,
# instead of always opening a new one. This leads to much
# quicker connection times.
ControlMaster auto
ControlPath ~/.ssh/control/%r@%h:%p
ControlPersist 1800

Compression yes
TCPKeepAlive yes
ServerAliveInterval 20
ServerAliveCountMax 10

Host HOSTNAME
  User YOUR_USERNAME
  ProxyJump none
  IdentityFile ~/.ssh/YOUR_SSH_KEY

Host *.BASEDOMAIN
  User YOUR_USERNAME
  ProxyJump  YOUR_USERNAME@HOSTNAME
  IdentityFile ~/.ssh/YOUR_SSH_KEY
EOF
echo ""

echo "replacing defaults with submitted values..."
if [[ $(uname) == "Darwin" ]]; then
  sed -i '' "s/YOUR_USERNAME/${USER}/g" ~/.ssh/config
  sed -i '' "s/YOUR_SSH_KEY/${KEY}/g" ~/.ssh/config
  sed -i '' "s/HOSTNAME/${HOSTNAME}/g" ~/.ssh/config
  sed -i '' "s/BASEDOMAIN/${BASEDOMAIN}/g" ~/.ssh/config
else
  sed -i "s/YOUR_USERNAME/${USER}/g" ~/.ssh/config
  sed -i "s/YOUR_SSH_KEY/${KEY}/g" ~/.ssh/config
  sed -i "s/HOSTNAME/${HOSTNAME}/g" ~/.ssh/config
  sed -i "s/BASEDOMAIN/${BASEDOMAIN}/g" ~/.ssh/config
fi
echo ""

echo "done."
