#!/bin/sh

set -euxv

KCADM=/opt/keycloak/bin/kcadm.sh

${KCADM} config credentials --server "$KC_INTERNAL_HOSTNAME_URL" --realm master --user "$KEYCLOAK_ADMIN" --password "$KEYCLOAK_ADMIN_PASSWORD"

${KCADM} update realms/master \
    -s 'displayName="Master Login"' \
    -s loginTheme=keywind

REALM_MASTER_FILE=/tmp/setup/realms/realm-master.json
if [ -f $REALM_MASTER_FILE ]; then
    ${KCADM} update realms/master -f $REALM_MASTER_FILE
fi
