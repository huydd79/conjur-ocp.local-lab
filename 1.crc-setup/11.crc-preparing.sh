#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

set -x
cd $UPLOAD_DIR
echo "Extracting crc zip file. This process will take few minutes..."
tar xvf $crc_zip_file
crc_dir=$(tar --exclude="*/*" -tf $crc_zip_file)

mv $UPLOAD_DIR/$crc_dir/crc /usr/local/bin/crc
echo "Creating crcuser for crc start up and operation"
useradd crcuser
passwd  crcuser
usermod -aG wheel crcuser

echo "please using ssh crcuser@localhost to login and continue next steps"

set +x
