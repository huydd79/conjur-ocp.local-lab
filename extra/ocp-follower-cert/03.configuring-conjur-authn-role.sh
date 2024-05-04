#/bin/sh
source 00.config.sh
node_name=conjur

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

oc project $FOLLOWER_NS
oc create serviceaccount $FOLLOWER_SA -n $FOLLOWER_NS
oc adm policy add-scc-to-user anyuid "system:serviceaccount:$FOLLOWER_NS:$FOLLOWER_SA"
#oc adm policy add-scc-to-user anyuid "system:serviceaccount:conjur:follower"

oc apply -f ./conjur-authenticator-role.yaml
#oc apply -f ./conjur-authenticator-role-binding.yaml
#oc apply -f ./conjur-authenticator-clusterole-binding.yaml


sudo yum install -y jq

TOKEN_SECRET_NAME="$(oc get secrets -n $FOLLOWER_NS \
| grep 'follower.*service-account-token' \
| head -n1 \
| awk '{print $1}')"

CA_CERT="$(oc get secret -n $FOLLOWER_NS $TOKEN_SECRET_NAME -o json \
| jq -r '.data["ca.crt"]' \
| base64 --decode)"

SERVICE_ACCOUNT_TOKEN="$(oc get secret -n $FOLLOWER_NS $TOKEN_SECRET_NAME -o json \
| jq -r .data.token \
| base64 --decode)"

API_URL="$(oc config view --minify -o json \
| jq -r '.clusters[0].cluster.server')"

conjur variable set -i conjur/authn-k8s/$AUTHENTICATOR_ID/kubernetes/ca-cert -v "$CA_CERT"
conjur variable set -i conjur/authn-k8s/$AUTHENTICATOR_ID/kubernetes/service-account-token -v "$SERVICE_ACCOUNT_TOKEN"
conjur variable set -i conjur/authn-k8s/$AUTHENTICATOR_ID/kubernetes/api-url -v "$API_URL"

API_HOST=$(echo $API_URL | sed 's/.*\/\///; s/:.*//')
sudo podman exec conjur sh -c "echo '$CONJUR_IP $API_HOST' >> /etc/hosts"

set +x