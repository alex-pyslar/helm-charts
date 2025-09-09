#!/bin/bash
set -e

check_tools() {
    command -v helm >/dev/null 2>&1 || { echo "Helm not installed!"; exit 1; }
    command -v kubectl >/dev/null 2>&1 || { echo "Kubectl not installed!"; exit 1; }
}

NAMESPACE=${NAMESPACE:-default}
RELEASE_VAULT="vault"
RELEASE_POSTGRES="postgres"
RELEASE_GITLAB="gitlab"
CHARTS_DIR="./charts"