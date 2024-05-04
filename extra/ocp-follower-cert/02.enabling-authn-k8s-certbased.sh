#/bin/sh
source 00.config.sh
node_name=conjur

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi
#Checking if running as root
if [[ "$(whoami)" == "root" ]]; then
    echo "Please run this script under crcuser"
    exit
fi

set -x
conjur -d policy load -f authn-k8s-certbased.yaml -b root

#Enabling all configured authn methods
tmp_file="/tmp/$(date +%s)-conjur.yml"
auth_json=$(curl -sk https://conjur-master.$LAB_DOMAIN/info | jq '.authenticators.configured')
cat << EOF > $tmp_file
#This file is created by script $0
authenticators: $auth_json
EOF
sudo podman exec -it $node_name sh -c "mv /etc/conjur/config/conjur.yml /etc/conjur/config/conjur.yml.bk.$(date +%s)"
sudo podman cp $tmp_file $node_name:/etc/conjur/config/conjur.yml
sudo podman exec conjur evoke configuration apply

#Initializing ca cert/key pair
sudo podman exec $node_name chpst -u conjur conjur-plugin-service possum rake --trace authn_k8s:ca_init["conjur/authn-k8s/$AUTHENTICATOR_ID"]

#Showing authn list
curl -sk https://conjur-master.$LAB_DOMAIN/info | jq '.authenticators'


set +x