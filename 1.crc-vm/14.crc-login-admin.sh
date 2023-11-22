#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

#Checking if running as root
if [[ "$(whoami)" == "root" ]]; then
    echo "Those scripts can not be run as root!"
    exit
fi

set -x

#Updating .bashrc
grep -q "crc status" ~/.bashrc || echo "crc status" >> ~/.bashrc
grep -q "eval \$(crc oc-env)" ~/.bashrc || echo "eval \$(crc oc-env)" >> ~/.bashrc
grep -q "crc console --credentials" ~/.bashrc || echo "crc console --credentials" >> ~/.bashrc


crc status
kubeadmin_login=$(crc console --credentials | grep admin | sed -s "s/.* '\(.*\)'/\1/")
developer_login=$(crc console --credentials | grep developer | sed -s "s/.* '\(.*\)'/\1/")
eval $(crc oc-env)
eval $kubeadmin_login
set +x
oc whoami

