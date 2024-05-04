#!/bin/sh

#Change your configuration and set READY=true when done
READY=false

#IP addresses of conjur and crc VM
CONJUR_IP=172.16.100.14
CRC_IP=$CONJUR_IP
LAB_DOMAIN=demo.local
LAB_CONJUR_ACCOUNT=DEMO

#Path to folder with all docker images
UPLOAD_DIR=/opt/lab/setup_files
crc_zip_file=crc-linux-amd64.tar.xz
pull_secret_file=pull-secret.txt
conjur_appliance_file=conjur-appliance-Rls-v13.2.0.tar.gz
conjur_cli_file=conjur-cli-go_8.0.12_linux_386.tar.gz


