#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi
node_name=conjur
sudo podman ps -a | grep $node_name >/dev/null 2>&1
if [ $? -eq 1 ]; then
    echo "Container $node_name is not existed. Creating new one..."
else
    echo "Container $node_name existed. Deleting old one..."
    sudo podman stop $node_name
    sudo podman container rm $(sudo podman ps -a | grep $node_name | awk '{print $1}')
fi

log_dir=/var/log/conjur/$node_name
set -x
sudo mkdir -p $log_dir

#Starting conjur container
sudo podman run --name $node_name \
  -d --restart=always \
  --dns $CONJUR_IP \
  -p "8443:443" \
  -p ""5432:5432" \
  --security-opt seccomp:unconfined \
  -v $log_dir:/var/log/conjur/:Z \
  --log-driver json-file \
  --log-opt max-size=1000m \
  --log-opt max-file=3 \
  registry.tld/conjur-appliance:$conjur_version

#Updating hosts file
sudo -- sh -c "grep -v 'conjur-master.$LAB_DOMAIN' /etc/hosts > /tmp/hosts"
sudo -- sh -c "echo '$CONJUR_IP $node_name.$LAB_DOMAIN conjur-master.$LAB_DOMAIN' >> /tmp/hosts"
sudo -- sh -c "cp /etc/hosts /etc/hosts.bk"
sudo -- sh -c "cp /tmp/hosts /etc/hosts"

#Evoking conjur to be master node
sudo podman exec $node_name evoke configure master \
    --accept-eula -h "conjur-master.$LAB_DOMAIN" \
    --master-altnames "$node_name.$LAB_DOMAIN" \
    -p $LAB_CONJUR_ADMIN_PW $LAB_CONJUR_ACCOUNT

set +x
