#!/bin/sh
source ../../2.conjur-setup/00.config.sh
#Change your configuration and set READY=true when done
READY=false

FOLLOWER_NS=conjur
FOLLOWER_SA=follower

CONJUR_APPLIANCE_URL=https://conjur-master.$LAB_DOMAIN
AUTHENTICATOR_ID=ocp
CONJUR_ACCOUNT=$LAB_CONJUR_ACCOUNT
CONJUR_SEED_FILE_URL=$CONJUR_APPLIANCE_URL/configuration/$CONJUR_ACCOUNT/seed/follower

