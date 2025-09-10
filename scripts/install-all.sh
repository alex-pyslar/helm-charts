#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/common.sh"
check_tools

# Create namespace if not exists
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Deploy Vault
echo "Deploying Vault..."
helm install "$RELEASE_VAULT" "$CHARTS_DIR/vault" --namespace "$NAMESPACE" --create-namespace --wait --timeout=10m || { echo "Vault deployment failed"; exit 1; }
kubectl wait --for=condition=ready pod -l app=vault --namespace "$NAMESPACE" --timeout=10m || { echo "Vault pods not ready"; exit 1; }

# Init Vault
echo "Initializing Vault..."
"$SCRIPT_DIR/vault-init.sh" || { echo "Vault init failed"; exit 1; }

# Deploy MinIO
echo "Deploying MinIO..."
helm install minio "$CHARTS_DIR/minio" --namespace "$NAMESPACE" --wait --timeout=10m || { echo "MinIO deployment failed"; exit 1; }
kubectl wait --for=condition=ready pod -l app=minio --namespace "$NAMESPACE" --timeout=10m || { echo "MinIO pods not ready"; exit 1; }

# Deploy Postgres
echo "Deploying Postgres..."
helm install "$RELEASE_POSTGRES" "$CHARTS_DIR/postgres" --namespace "$NAMESPACE" --set vault.enabled=true --wait --timeout=10m || { echo "Postgres deployment failed"; exit 1; }
kubectl wait --for=condition=ready pod -l app=postgres --namespace "$NAMESPACE" --timeout=10m || { echo "Postgres pods not ready"; exit 1; }

# Deploy Redis for GitLab
echo "Deploying Redis for GitLab..."
helm install gitlab-redis "$CHARTS_DIR/redis" --namespace "$NAMESPACE" --set vault.enabled=true --wait --timeout=10m || { echo "GitLab Redis deployment failed"; exit 1; }
kubectl wait --for=condition=ready pod -l app=gitlab-redis --namespace "$NAMESPACE" --timeout=10m || { echo "GitLab Redis pods not ready"; exit 1; }

# Deploy Redis for Nextcloud
echo "Deploying Redis for Nextcloud..."
helm install nextcloud-redis "$CHARTS_DIR/redis" --namespace "$NAMESPACE" --set vault.enabled=true --wait --timeout=10m || { echo "Nextcloud Redis deployment failed"; exit 1; }
kubectl wait --for=condition=ready pod -l app=nextcloud-redis --namespace "$NAMESPACE" --timeout=10m || { echo "Nextcloud Redis pods not ready"; exit 1; }

# Deploy GitLab
echo "Deploying GitLab..."
helm install "$RELEASE_GITLAB" "$CHARTS_DIR/gitlab" --namespace "$NAMESPACE" \
  --set global.postgres.host="$RELEASE_POSTGRES-postgres" \
  --set global.redis.host=gitlab-redis-redis \
  --set global.minio.host=minio-minio --wait --timeout=15m || { echo "GitLab deployment failed"; exit 1; }
kubectl wait --for=condition=ready pod -l app=gitlab --namespace "$NAMESPACE" --timeout=15m || { echo "GitLab pods not ready"; exit 1; }

# Deploy Nextcloud
echo "Deploying Nextcloud..."
helm install nextcloud "$CHARTS_DIR/nextcloud" --namespace "$NAMESPACE" --set vault.enabled=true \
  --set postgres.host="$RELEASE_POSTGRES-postgres" \
  --set redis.host=nextcloud-redis-redis --wait --timeout=15m || { echo "Nextcloud deployment failed"; exit 1; }
kubectl wait --for=condition=ready pod -l app=nextcloud --namespace "$NAMESPACE" --timeout=15m || { echo "Nextcloud pods not ready"; exit 1; }

echo "All deployed!"
echo "Access GitLab at $(kubectl get svc "$RELEASE_GITLAB-gitlab" -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo 'http://localhost:80 via kubectl port-forward svc/gitlab-gitlab 80:80 -n $NAMESPACE')"
echo "Access Nextcloud at $(kubectl get svc nextcloud-nextcloud -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo 'http://localhost:80 via kubectl port-forward svc/nextcloud-nextcloud 80:80 -n $NAMESPACE')"