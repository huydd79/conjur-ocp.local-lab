#!/bin/sh

#Change your configuration and set READY=true when done
READY=false

#IP addresses of conjur and crc VM
CONJUR_IP=172.16.100.14
LAB_IP=$CONJUR_IP
LAB_DOMAIN=demo.local
LAB_CONJUR_ADMIN_PW=ChangeMe123!
LAB_CONJUR_ACCOUNT=DEMO
#Path to folder with all docker images
UPLOAD_DIR=/opt/lab/setup_files
conjur_appliance_file=conjur-appliance-Rls-v13.1.0.tar.gz
conjur_cli_file=conjur-cli-go_8.0.12_linux_386.tar.gz
conjur_version=13.1.0


