#!/bin/sh

set -euxv

KCADM=/opt/keycloak/bin/kcadm.sh

${KCADM} config credentials --server "$KC_INTERNAL_HOSTNAME_URL" --realm master --user "$KEYCLOAK_ADMIN" --password "$KEYCLOAK_ADMIN_PASSWORD"

${KCADM} create realms \
    -s "realm=${OIDC_ADMIN_REALM}" \
    -s enabled=true \
    -s displayName="${OIDC_ADMIN_REALM_DISPLAY_NAME}" \
    -s accessTokenLifespan=300 \
    -s ssoSessionIdleTimeout=3600 \
    -s ssoSessionMaxLifespan=3600 \
    -s revokeRefreshToken=true \
    -s refreshTokenMaxReuse=0 \
    -s defaultSignatureAlgorithm=RS256 \
    -s editUsernameAllowed=false \
    -s registrationEmailAsUsername=true \
    -s registrationAllowed=false \
    -s resetPasswordAllowed=true \
    -s rememberMe=true \
    -s duplicateEmailsAllowed=false \
    -s loginTheme=keywind

${KCADM} create clients -r ${OIDC_ADMIN_REALM} -f - <<EOF
{
    "protocol": "openid-connect",
    "clientId": "${OIDC_ADMIN_APP_ID}",
    "directAccessGrantsEnabled": true,
    "webOrigins": ["*"],
    "redirectUris": ["*"],
    "standardFlowEnabled": true,
    "clientAuthenticatorType": "client-secret",
    "secret": "${OIDC_ADMIN_APP_SECRET}",
    "bearerOnly": false,
    "publicClient": false,
    "serviceAccountsEnabled": true,
    "authorizationServicesEnabled": true,
    "attributes": {
        "client_credentials.use_refresh_token": true
    }
}
EOF

${KCADM} create clients -r ${OIDC_ADMIN_REALM} -f - <<EOF
{
    "protocol": "openid-connect",
    "clientId": "${OIDC_ADMIN_USER_ID}",
    "directAccessGrantsEnabled": true,
    "webOrigins": ["*"],
    "redirectUris": ["*"],
    "bearerOnly": false,
    "standardFlowEnabled": true,
    "publicClient": true,
    "serviceAccountsEnabled": false,
    "authorizationServicesEnabled": false,
    "attributes": {
        "client_credentials.use_refresh_token": true
    }
}
EOF

### Users
${KCADM} create users -r ${OIDC_ADMIN_REALM} -s enabled=true -s emailVerified=true -s username=john.doe@wayof.dev -s email=john.doe@wayof.dev -s firstName=John -s lastName=Doe
${KCADM} set-password -r ${OIDC_ADMIN_REALM} --username john.doe@wayof.dev --new-password john.doe

${KCADM} create users -r ${OIDC_ADMIN_REALM} -s enabled=true -s emailVerified=true -s username=jane.doe@wayof.dev -s email=jane.doe@wayof.dev -s firstName=Jane -s lastName=Doe
${KCADM} set-password -r ${OIDC_ADMIN_REALM} --username jane.doe@wayof.dev --new-password jane.doe

${KCADM} create users -r ${OIDC_ADMIN_REALM} -s enabled=true -s emailVerified=true -s username=johnny.doe@wayof.dev -s email=johnny.doe@wayof.dev -s firstName=Johnny -s lastName=Doe
${KCADM} set-password -r ${OIDC_ADMIN_REALM} --username johnny.doe@wayof.dev --new-password johnny.doe

### Roles
${KCADM} add-roles \
    -r ${OIDC_ADMIN_REALM} \
    --uusername "service-account-${OIDC_ADMIN_APP_ID}" \
    --cclientid realm-management \
    --rolename manage-users
