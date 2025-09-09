#!/bin/bash
source ./scripts/common.sh
check_tools

helm upgrade $RELEASE_VAULT $CHARTS_DIR/vault --namespace $NAMESPACE
helm upgrade $RELEASE_POSTGRES $CHARTS_DIR/postgres --namespace $NAMESPACE
helm upgrade $RELEASE_GITLAB $CHARTS_DIR/gitlab --namespace $NAMESPACE
echo "All upgraded!"