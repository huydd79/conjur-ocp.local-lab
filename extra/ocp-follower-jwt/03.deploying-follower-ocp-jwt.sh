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
CONJUR_APPLIANCE_URL=https://conjur-master.$LAB_DOMAIN
AUTHENTICATOR_ID=k8s
CONJUR_ACCOUNT=$LAB_CONJUR_ACCOUNT
CONJUR_SEED_FILE_URL=$CONJUR_APPLIANCE_URL/configuration/$CONJUR_ACCOUNT/seed/follower

eval $(crc oc-env)

set -x

#Delete current deployment
oc -n $FOLLOWER_NS get deployments | grep -q follower
if [ $? -eq 0 ]; then
    oc -n $FOLLOWER_NS delete deployment follower
    ret=0
    until [ $ret -ne 0 ]
    do
        oc -n $FOLLOWER_NS get deployments | grep -q follower
        ret=$?
        echo "Waiting deployment is deleted..."
        sleep 1
    done

fi

# Allow running conjur follower with privilege (required by standalone follower)
# In production env, need to consisder more secure way
oc create sa follower
oc adm policy add-scc-to-user privileged -z follower


tmp_file="/tmp/$(date +%s)-follower.yaml"

cp follower-ocp-jwt.yaml $tmp_file
sed -i "s/CONJUR_IP/$CONJUR_IP/g" $tmp_file
sed -i "s/LAB_DOMAIN/$LAB_DOMAIN/g" $tmp_file
sed -i "s/CONJUR_VERSION/$conjur_version/g" $tmp_file

oc -n $FOLLOWER_NS apply -f $tmp_file

rm $tmp_file

set +x