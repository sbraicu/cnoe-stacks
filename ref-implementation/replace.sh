# this script replaces hostname and port used by this implementation.
# intended for use in environments such as Codespaces where external host and port need to be updated to access in-cluster resources.

#!/bin/bash
set -e
if [ "$#" -ne 2 ]; then
  echo "Usage: NEW_HOST NEW_PORT"; exit 1; fi
NEW_HOST="$1"; NEW_PORT="$2"

CURRENT_DIR=${PWD##*/}; [[ $CURRENT_DIR == "ref-implementation" ]] || { echo "run from ref-implementation"; exit 10; }

# Detect GNU vs BSD sed
if sed --version >/dev/null 2>&1; then
  SED_INPLACE=(-i)               # GNU
  FIRST_ONLY_RANGE='0,/:443/ s/:443//'
else
  SED_INPLACE=(-i '')            # BSD/macOS
  FIRST_ONLY_RANGE='1,/:443/ s/:443//'
fi

# Bulk replacements
find . -type f -name "*.yaml" -exec sed "${SED_INPLACE[@]}" "s/8443/${NEW_PORT}/g" {} +
find . -type f -name "*.yaml" -exec sed "${SED_INPLACE[@]}" "s/cnoe\.localtest\.me/${NEW_HOST}/g" {} +

# Port=443 special handling
if [[ ${NEW_PORT} == "443" ]]; then
  sed "${SED_INPLACE[@]}" "/hostname-port/d" keycloak/manifests/install.yaml
  sed "${SED_INPLACE[@]}" "/hostname-admin/d" keycloak/manifests/install.yaml
  sed "${SED_INPLACE[@]}" "${FIRST_ONLY_RANGE}" argo-workflows/manifests/dev/patches/cm-argo-workflows.yaml
fi
echo "Replacement complete."
