#!/bin/bash
# This script updates the configuration values for backstage, keycloak, and argo-workflows
# to use the new environment variable approach instead of hardcoded values.

set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 NEW_HOST NEW_PORT"
    echo "Example: $0 outshift-lab-yye6819.demos.eticloud.io 6110"
    exit 1
fi

NEW_HOST="$1"
NEW_PORT="$2"
PROTOCOL="https"

echo "Updating configuration for host: $NEW_HOST, port: $NEW_PORT"

# Update global-config.yaml
echo "Updating global-config.yaml..."
sed -i "s/HOST: \".*\"/HOST: \"$NEW_HOST\"/" global-config.yaml
sed -i "s/PORT: \".*\"/PORT: \"$NEW_PORT\"/" global-config.yaml
sed -i "s/BASE_URL: \".*\"/BASE_URL: \"$PROTOCOL:\/\/$NEW_HOST:$NEW_PORT\"/" global-config.yaml
sed -i "s/BASE_URL_NO_PORT: \".*\"/BASE_URL_NO_PORT: \"$PROTOCOL:\/\/$NEW_HOST\"/" global-config.yaml
sed -i "s/BACKSTAGE_URL: \".*\"/BACKSTAGE_URL: \"$PROTOCOL:\/\/$NEW_HOST:$NEW_PORT\/backstage\"/" global-config.yaml
sed -i "s/ARGOCD_URL: \".*\"/ARGOCD_URL: \"$PROTOCOL:\/\/$NEW_HOST:$NEW_PORT\/argocd\"/" global-config.yaml
sed -i "s/GITEA_URL: \".*\"/GITEA_URL: \"$PROTOCOL:\/\/$NEW_HOST:$NEW_PORT\/gitea\"/" global-config.yaml
sed -i "s/KEYCLOAK_URL: \".*\"/KEYCLOAK_URL: \"$PROTOCOL:\/\/$NEW_HOST:$NEW_PORT\/keycloak\"/" global-config.yaml
sed -i "s/ARGO_WORKFLOWS_URL: \".*\"/ARGO_WORKFLOWS_URL: \"$PROTOCOL:\/\/$NEW_HOST:$NEW_PORT\/argo-workflows\"/" global-config.yaml
sed -i "s/GITEA_HOST: \".*\"/GITEA_HOST: \"$NEW_HOST:$NEW_PORT\"/" global-config.yaml
sed -i "s/GITEA_HOST_NO_PORT: \".*\"/GITEA_HOST_NO_PORT: \"$NEW_HOST\"/" global-config.yaml
sed -i "s/GITEA_CATALOG_URL: \".*\"/GITEA_CATALOG_URL: \"$PROTOCOL:\/\/$NEW_HOST\/gitea\/giteaAdmin\/idpbuilder-localdev-backstage-templates-entities\/raw\/branch\/main\/catalog-info.yaml\"/" global-config.yaml
sed -i "s/KEYCLOAK_METADATA_URL: \".*\"/KEYCLOAK_METADATA_URL: \"$PROTOCOL:\/\/$NEW_HOST:$NEW_PORT\/keycloak\/realms\/cnoe\/.well-known\/openid-configuration\"/" global-config.yaml

# Update keycloak config secret
echo "Updating keycloak config secret..."
sed -i "s/KEYCLOAK_HOSTNAME: \".*\"/KEYCLOAK_HOSTNAME: \"$NEW_HOST\"/" keycloak/manifests/keycloak-config-secret.yaml
sed -i "s/KEYCLOAK_PORT: \".*\"/KEYCLOAK_PORT: \"$NEW_PORT\"/" keycloak/manifests/keycloak-config-secret.yaml

# Update argo-workflows config secret
echo "Updating argo-workflows config secret..."
sed -i "s/KEYCLOAK_ISSUER: \".*\"/KEYCLOAK_ISSUER: \"$PROTOCOL:\/\/$NEW_HOST:$NEW_PORT\/keycloak\/realms\/cnoe\"/" argo-workflows/manifests/dev/argo-workflows-config-secret.yaml
sed -i "s/REDIRECT_URL: \".*\"/REDIRECT_URL: \"$PROTOCOL:\/\/$NEW_HOST:$NEW_PORT\/argo-workflows\/oauth2\/callback\"/" argo-workflows/manifests/dev/argo-workflows-config-secret.yaml

# Update backstage config secret
echo "Updating backstage config secret..."
sed -i "s/BACKSTAGE_BASE_URL: \".*\"/BACKSTAGE_BASE_URL: \"$PROTOCOL:\/\/$NEW_HOST:$NEW_PORT\"/" backstage/manifests/backstage-config-secret.yaml
sed -i "s/GITEA_BASE_URL: \".*\"/GITEA_BASE_URL: \"$PROTOCOL:\/\/$NEW_HOST:$NEW_PORT\/gitea\"/" backstage/manifests/backstage-config-secret.yaml
sed -i "s/GITEA_HOST: \".*\"/GITEA_HOST: \"$NEW_HOST:$NEW_PORT\"/" backstage/manifests/backstage-config-secret.yaml
sed -i "s/GITEA_BASE_URL_NO_PORT: \".*\"/GITEA_BASE_URL_NO_PORT: \"$PROTOCOL:\/\/$NEW_HOST\/gitea\"/" backstage/manifests/backstage-config-secret.yaml
sed -i "s/GITEA_HOST_NO_PORT: \".*\"/GITEA_HOST_NO_PORT: \"$NEW_HOST\"/" backstage/manifests/backstage-config-secret.yaml
sed -i "s/GITEA_CATALOG_URL: \".*\"/GITEA_CATALOG_URL: \"$PROTOCOL:\/\/$NEW_HOST\/gitea\/giteaAdmin\/idpbuilder-localdev-backstage-templates-entities\/raw\/branch\/main\/catalog-info.yaml\"/" backstage/manifests/backstage-config-secret.yaml
sed -i "s/ARGOCD_URL: \".*\"/ARGOCD_URL: \"$PROTOCOL:\/\/$NEW_HOST:$NEW_PORT\/argocd\"/" backstage/manifests/backstage-config-secret.yaml
sed -i "s/ARGO_WORKFLOWS_URL: \".*\"/ARGO_WORKFLOWS_URL: \"$PROTOCOL:\/\/$NEW_HOST:$NEW_PORT\/argo-workflows\"/" backstage/manifests/backstage-config-secret.yaml
sed -i "s/KEYCLOAK_NAME_METADATA: \".*\"/KEYCLOAK_NAME_METADATA: \"$PROTOCOL:\/\/$NEW_HOST:$NEW_PORT\/keycloak\/realms\/cnoe\/.well-known\/openid-configuration\"/" backstage/manifests/backstage-config-secret.yaml

echo "Configuration update complete!"
echo ""
echo "The following services now use environment variables instead of hardcoded values:"
echo "- Backstage: Uses global-config ConfigMap and environment variables"
echo "- Keycloak: Uses keycloak-config-secret and environment variables"
echo "- Argo-workflows: Uses argo-workflows-config-secret and environment variables"
echo ""
echo "To apply these changes, you may need to restart the pods or update the deployments."
