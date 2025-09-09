#!/bin/bash
source ./scripts/common.sh
check_tools

helm uninstall $RELEASE_GITLAB --namespace $NAMESPACE
helm uninstall $RELEASE_POSTGRES --namespace $NAMESPACE
helm uninstall $RELEASE_VAULT --namespace $NAMESPACE
echo "All uninstalled! (PVC may persist)"