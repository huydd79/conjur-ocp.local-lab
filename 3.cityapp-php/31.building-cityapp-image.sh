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

cd build
sudo podman build -t cityapp-php .
cd ..
sudo podman image ls | grep cityapp

echo "Pushing cityapp image to openshift image registry..."
crchost=default-route-openshift-image-registry.apps-crc.testing
sudo mkdir -p /etc/docker/certs.d/$crchost
openssl s_client -showcerts -connect $crchost:443 -servername $crchost \
    </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' \
    > /tmp/ca.crt
sudo mv /tmp/ca.crt /etc/docker/certs.d/$crchost/ca.crt

oc new-project cityapp
sudo podman login -u _ -p $(oc whoami -t) $crchost
sudo podman tag cityapp-php $crchost/cityapp/cityapp
sudo podman push $crchost/cityapp/cityapp

oc get is

set +x