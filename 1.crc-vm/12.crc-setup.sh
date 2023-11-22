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
cd $UPLOAD_DIR
crc_dir=$(tar xvf $crc_zip_file | head -n 1)
ln -s $UPLOAD_DIR/$crc_dir/crc /usr/local/bin/crc

crc config set consent-telemetry yes
crc setup --log-level debug
set +x