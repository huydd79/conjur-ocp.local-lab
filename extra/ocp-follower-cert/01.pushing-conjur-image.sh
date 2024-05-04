#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi
#Checking if running as root
if [[ "$(whoami)" == "root" ]]; then
    echo "Please run this script under crcuser"
    exit
fi

eval $(crc oc-env)
set -x

sudo podman image ls | grep conjur

echo "Pushing conjur image to openshift image registry..."
crchost=default-route-openshift-image-registry.apps-crc.testing
sudo mkdir -p /etc/docker/certs.d/$crchost
openssl s_client -showcerts -connect $crchost:443 -servername $crchost \
    </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' \
    > /tmp/ca.crt
sudo mv /tmp/ca.crt /etc/docker/certs.d/$crchost/ca.crt

oc new-project $FOLLOWER_NS
sudo podman login -u _ -p $(oc whoami -t) $crchost
sudo podman tag registry.tld/conjur-appliance:$conjur_version $crchost/$FOLLOWER_NS/conjur-appliance
sudo podman push $crchost/$FOLLOWER_NS/conjur-appliance

oc get is --all-namespaces | grep conjur-appliance

set +x