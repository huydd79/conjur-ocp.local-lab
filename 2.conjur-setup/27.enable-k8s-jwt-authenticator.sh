#/bin/sh
source 00.config.sh
node_name="conjur"

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
conjur -d policy load -f ./policies/authn-jwt-k8s.yaml -b root

sudo podman exec $node_name chpst -u conjur conjur-plugin-service possum rake authn_k8s:ca_init["conjur/authn-jwt/k8s"]
sudo podman exec -it $node_name sh -c 'grep -q "authn,authn-jwt/k8s" /opt/conjur/etc/conjur.conf || echo "CONJUR_AUTHENTICATORS=\"authn,authn-jwt/k8s\"\n">>/opt/conjur/etc/conjur.conf'
sudo podman exec $node_name sv restart conjur
set +x
