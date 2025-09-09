#!/bin/bash
source ./scripts/common.sh
check_tools

helm install $RELEASE_VAULT $CHARTS_DIR/vault --namespace $NAMESPACE --create-namespace
kubectl wait --for=condition=ready pod -l app=vault --namespace $NAMESPACE --timeout=5m

./scripts/vault-init.sh

helm install $RELEASE_POSTGRES $CHARTS_DIR/postgres --namespace $NAMESPACE --set vault.enabled=true
kubectl wait --for=condition=ready pod -l app=postgres --namespace $NAMESPACE --timeout=5m

helm install $RELEASE_GITLAB $CHARTS_DIR/gitlab --namespace $NAMESPACE --set global.postgres.host=$RELEASE_POSTGRES-postgres
kubectl wait --for=condition=ready pod -l app=gitlab --namespace $NAMESPACE --timeout=10m

echo "All deployed! Access GitLab at $(kubectl get svc $RELEASE_GITLAB -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"