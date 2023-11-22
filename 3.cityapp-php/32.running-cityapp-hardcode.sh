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

APP_NAME="cityapp-hardcode"
YML_FILE="yaml/$APP_NAME.yaml"
YML_TEMP="/tmp/$APP_NAME.yaml"

eval $(crc oc-env)
set -x
oc get namespace | grep -q cityapp || oc create namespace cityapp
oc -n cityapp get deployments | grep -q $APP_NAME
if [ $? -eq 0 ]; then
    oc -n cityapp delete deployment $APP_NAME
    ret=0
    until [ $ret -ne 0 ]
    do
        oc -n cityapp get deployments | grep -q $APP_NAME
        ret=$?
        echo "Waiting deployment is deleted..."
        sleep 1
    done
    
fi

cp $YML_FILE $YML_TEMP
sed -i "s/{LAB_IP}/$LAB_IP/g" $YML_TEMP
sed -i "s/{LAB_DOMAIN}/$LAB_DOMAIN/g" $YML_TEMP

oc adm policy add-scc-to-user anyuid system:serviceaccount:cityapp:cityapp-hardcode
oc -n cityapp apply -f $YML_TEMP

rm $YML_TEMP
set +x