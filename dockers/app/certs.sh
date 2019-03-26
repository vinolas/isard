#!/bin/bash

### If no id_rsa.pub key yet, create new one

auth_keys="/root/.ssh/id_rsa.pub"
if [ -f "$auth_keys" ]
then
    echo "$auth_keys found, so not generating new ones."
else
    echo "$auth_keys not found, generating new ones."
    cat /dev/zero | ssh-keygen -q -N ""
    #Copy new host key to authorized_keys (so isard-hypervisor can get it also)
    #This way no password needed.
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
fi

# Remove all isard-hypervisor lines from known_hosts
sed -i '/isard-hypervisor/d' /root/.ssh/known_hosts

echo "Checking for isard-hypervisor ssh..."

i=0
while ! nc -z isard-hypervisor 22; do   
  sleep 0.5
  ((i++))
  if [[ "$i" == '25' ]]; then
    break
  fi  
  echo "Checking for isard-hypervisor shh"
done

if [[ "$i" -ne '25' ]]; then
  echo "Adding isard-hypervisor keys"
  ssh-keyscan -T 10 isard-hypervisor > /root/.ssh/known_hosts
else
  echo "Assuming that there is no isard-hypervisor available"
fi 
