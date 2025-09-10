#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/common.sh"
check_tools

# Deploy Vault
helm install $RELEASE_VAULT "$CHARTS_DIR/vault" --namespace "$NAMESPACE" --create-namespace
kubectl wait --for=condition=ready pod -l app=vault --namespace "$NAMESPACE" --timeout=5m

# Init Vault
"$SCRIPT_DIR/vault-init.sh"

# Deploy MinIO
helm install minio "$CHARTS_DIR/minio" --namespace "$NAMESPACE"
kubectl wait --for=condition=ready pod -l app=minio --namespace "$NAMESPACE" --timeout=5m

# Deploy Postgres
helm install $RELEASE_POSTGRES "$CHARTS_DIR/postgres" --namespace "$NAMESPACE" --set vault.enabled=true
kubectl wait --for=condition=ready pod -l app=postgres --namespace "$NAMESPACE" --timeout=5m

# Deploy Redis for GitLab
helm install gitlab-redis "$CHARTS_DIR/redis" --namespace "$NAMESPACE" --set vault.enabled=true
kubectl wait --for=condition=ready pod -l app=gitlab-redis --namespace "$NAMESPACE" --timeout=5m

# Deploy Redis for Nextcloud
helm install nextcloud-redis "$CHARTS_DIR/redis" --namespace "$NAMESPACE" --set vault.enabled=true
kubectl wait --for=condition=ready pod -l app=nextcloud-redis --namespace "$NAMESPACE" --timeout=5m

# Deploy GitLab
helm install $RELEASE_GITLAB "$CHARTS_DIR/gitlab" --namespace "$NAMESPACE" \
  --set global.postgres.host=$RELEASE_POSTGRES-postgres \
  --set global.redis.host=gitlab-redis-redis \
  --set global.minio.host=minio-minio
kubectl wait --for=condition=ready pod -l app=gitlab --namespace "$NAMESPACE" --timeout=10m

# Deploy Nextcloud
helm install nextcloud "$CHARTS_DIR/nextcloud" --namespace "$NAMESPACE" --set vault.enabled=true \
  --set postgres.host=$RELEASE_POSTGRES-postgres \
  --set redis.host=nextcloud-redis-redis
kubectl wait --for=condition=ready pod -l app=nextcloud --namespace "$NAMESPACE" --timeout=10m

echo "All deployed!"
echo "Access GitLab at $(kubectl get svc $RELEASE_GITLAB -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' || echo 'http://localhost:80 via port-forward')"
echo "Access Nextcloud at $(kubectl get svc nextcloud -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' || echo 'http://localhost:80 via port-forward')"