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

#Downloading necessary packages for app building
sudo dnf install -y java-17-openjdk java-17-openjdk-devel

cd build
sudo bash -c "./mvnw clean package"
sudo podman build -t cityapp-springboot .
cd ..
sudo podman image ls | grep cityapp-springboot

echo "Pushing cityapp-springboot image to openshift image registry..."
crchost=default-route-openshift-image-registry.apps-crc.testing
sudo mkdir -p /etc/docker/certs.d/$crchost
openssl s_client -showcerts -connect $crchost:443 -servername $crchost \
    </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' \
    > /tmp/ca.crt
sudo mv /tmp/ca.crt /etc/docker/certs.d/$crchost/ca.crt

oc new-project cityapp
sudo podman login -u _ -p $(oc whoami -t) $crchost
sudo podman tag cityapp-springboot $crchost/cityapp/cityapp-springboot
sudo podman push $crchost/cityapp/cityapp-springboot

oc get is

set +x