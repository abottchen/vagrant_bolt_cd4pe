#!/bin/bash
PUPPETBIN="/opt/puppetlabs/bin/puppet"
id=$(curl -s -X GET https://$(hostname -f):4433/classifier-api/v1/groups \
  --cert $(${PUPPETBIN} config print hostcert) \
  --key $(${PUPPETBIN} config print hostprivkey) \
  --cacert $(${PUPPETBIN} config print localcacert) \
  -H "Content-Type: application/json" | /usr/local/bin/jq -r '.[] | select(.name=="PE Master") | .id')

if [ ${PIPESTATUS[0]} -eq 0 ]; then
  echo "PE Master group id: '${id}'"
else
  echo "Could not find PE Master node group id!"
  exit 1
fi

curl -X POST -H "Content-type: application/json" \
--data \
'{
  "classes":  {
    "puppet_enterprise::profile::master": {
      "code_manager_auto_configure": true,
      "r10k_private_key": "/etc/puppetlabs/puppetserver/ssh.key",
      "r10k_remote": "ssh://git@infra.puppetdebug.vlan:8022/root/control-repo.git"
    }
  }
}' \
--cert   $(${PUPPETBIN} config print hostcert) \
--key    $(${PUPPETBIN} config print hostprivkey) \
--cacert $(${PUPPETBIN} config print localcacert) \
https://$(hostname -f):4433/classifier-api/v1/groups/${id} > /dev/null

if [ $? -eq 0 ]; then
  echo "Group updated"
else
  echo "Could not update PE Master node group!"
  exit 1
fi
