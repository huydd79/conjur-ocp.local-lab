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
tmp_file="/tmp/$(date +%s)-conjur.pem"
openssl s_client -showcerts -connect conjur-master.$LAB_DOMAIN:443 < /dev/null 2> /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $tmp_file

CONJUR_SSL_CERTIFICATE=$tmp_file

oc create configmap follower-cm -n $FOLLOWER_NS \
  -o yaml \
  --dry-run=client \
  --from-literal CONJUR_ACCOUNT=${CONJUR_ACCOUNT} \
  --from-literal CONJUR_APPLIANCE_URL=${CONJUR_APPLIANCE_URL} \
  --from-literal CONJUR_SEED_FILE_URL=${CONJUR_SEED_FILE_URL} \
  --from-literal AUTHENTICATOR_ID=${AUTHENTICATOR_ID} \
  --from-file "CONJUR_SSL_CERTIFICATE=${CONJUR_SSL_CERTIFICATE}" \
  | oc apply -f -

rm $tmp_file
set +x