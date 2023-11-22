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
set -x
cli_file=$(sudo tar xvf  $UPLOAD_DIR/$conjur_cli_file | grep "/conjur")
if [ -z $cli_file ]; then
    echo "ERROR: CLI file unzip failed..."
else
    sudo chmod +x $cli_file
    sudo cp $cli_file /usr/local/bin
    conjur init -u https://conjur-master.$LAB_DOMAIN -a $LAB_CONJUR_ACCOUNT --self-signed --force
    conjur login -i admin
    set +x
    conjur whoami
fi
