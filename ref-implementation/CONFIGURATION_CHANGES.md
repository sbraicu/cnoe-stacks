# Configuration Changes for Dynamic Host and Port Support

This document describes the changes made to enable backstage, keycloak, and argo-workflows to use dynamic host and port values from the idpbuilder command line arguments, similar to how argocd and gitea work.

## Overview

Previously, backstage, keycloak, and argo-workflows used hardcoded values like `cnoe.localtest.me:8443` in their configuration files. This made it difficult to deploy to different environments with different hostnames and ports.

The new implementation uses environment variables and ConfigMaps that can be dynamically updated based on the idpbuilder command line arguments.

## Changes Made

### 1. Global Configuration (global-config.yaml)

Created a new global configuration file that centralizes all host and port related configuration:

- **Location**: `ref-implementation/global-config.yaml`
- **Purpose**: Provides a single source of truth for all service URLs and endpoints
- **Usage**: Referenced by backstage, keycloak, and argo-workflows

### 2. Backstage Configuration Updates

#### Files Modified:
- `ref-implementation/backstage/manifests/install.yaml`
- `ref-implementation/backstage/manifests/backstage-config-secret.yaml`

#### Changes:
- Replaced hardcoded URLs with environment variable references (e.g., `${BACKSTAGE_BASE_URL}`)
- Added environment variables to the backstage container that reference the global config
- Updated external secrets to use the new configuration values

### 3. Keycloak Configuration Updates

#### Files Modified:
- `ref-implementation/keycloak/manifests/install.yaml`
- `ref-implementation/keycloak/manifests/keycloak-config-secret.yaml`

#### Changes:
- Replaced hardcoded hostname configuration with environment variables
- Added environment variables to the keycloak container
- Created a secret for keycloak configuration values

### 4. Argo-workflows Configuration Updates

#### Files Modified:
- `ref-implementation/argo-workflows/manifests/dev/patches/cm-argo-workflows.yaml`
- `ref-implementation/argo-workflows/manifests/dev/patches/deployment-argo-server.yaml`
- `ref-implementation/argo-workflows/manifests/dev/argo-workflows-config-secret.yaml`
- `ref-implementation/argo-workflows/manifests/dev/external-secret.yaml`

#### Changes:
- Replaced hardcoded URLs with environment variable references
- Added environment variables to the argo-server container
- Created secrets for argo-workflows configuration values

## How It Works

1. **Global Config**: The `global-config.yaml` file contains all the configuration values
2. **Environment Variables**: Each service container has environment variables that reference the global config
3. **Dynamic Updates**: The `update-config.sh` script can update all configuration values at once
4. **Service Restart**: After updating the config, services need to be restarted to pick up the new values

## Usage

### Option 1: Use the update-config.sh script (Recommended)

```bash
cd ref-implementation
./update-config.sh outshift-lab-yye6819.demos.eticloud.io 6110
```

### Option 2: Use the existing replace.sh script

```bash
cd ref-implementation
./replace.sh outshift-lab-yye6819.demos.eticloud.io 6110
```

### Option 3: Manual updates

Update the values in the following files:
- `global-config.yaml`
- `keycloak/manifests/keycloak-config-secret.yaml`
- `argo-workflows/manifests/dev/argo-workflows-config-secret.yaml`
- `backstage/manifests/backstage-config-secret.yaml`

## Benefits

1. **Dynamic Configuration**: Services can now use different hostnames and ports without code changes
2. **Environment Flexibility**: Easy to deploy to different environments (dev, staging, production)
3. **Consistency**: All services use the same configuration source
4. **Maintainability**: Single place to update configuration values

## Limitations

1. **Service Restart Required**: Changes require pod restarts to take effect
2. **Manual Updates**: Configuration updates are not fully automated by idpbuilder yet
3. **Backward Compatibility**: The old hardcoded approach is still supported for existing deployments

## Future Improvements

1. **idpbuilder Integration**: Modify idpbuilder to automatically update these configuration files
2. **Hot Reload**: Implement configuration hot-reloading without pod restarts
3. **Validation**: Add validation for configuration values
4. **Templates**: Use Kubernetes ConfigMap templates for more dynamic configuration

## Troubleshooting

### Common Issues

1. **Configuration Not Applied**: Ensure pods are restarted after configuration changes
2. **Environment Variables Missing**: Check that the ConfigMaps are properly mounted
3. **URL Mismatches**: Verify that all configuration files are updated consistently

### Debugging

1. Check pod environment variables:
   ```bash
   kubectl exec -n backstage <pod-name> -- env | grep -E "(HOST|PORT|URL)"
   ```

2. Check ConfigMap values:
   ```bash
   kubectl get configmap global-config -n argocd -o yaml
   ```

3. Check pod logs for configuration errors:
   ```bash
   kubectl logs -n backstage <pod-name>
   ```
