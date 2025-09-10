#!/bin/bash
source ./scripts/common.sh
check_tools

POD_NAME=$(kubectl get pods -l app=vault -o jsonpath='{.items[0].metadata.name}' -n $NAMESPACE)
kubectl exec -it $POD_NAME -n $NAMESPACE -- vault operator init > vault-init.txt

echo "Enter unseal keys manually from vault-init.txt..."
for i in {1..3}; do
    read -p "Unseal key $i: " KEY
    kubectl exec $POD_NAME -n $NAMESPACE -- vault operator unseal $KEY
done

ROOT_TOKEN=$(grep 'Root Token' vault-init.txt | awk '{print $4}')
kubectl exec $POD_NAME -n $NAMESPACE -- vault login $ROOT_TOKEN
kubectl exec $POD_NAME -n $NAMESPACE -- vault secrets enable -path=secret kv-v2
kubectl exec $POD_NAME -n $NAMESPACE -- vault kv put secret/postgres password=supersecret dbname=mydb
kubectl exec $POD_NAME -n $NAMESPACE -- vault kv put secret/gitlab-redis password=redis-secret
kubectl exec $POD_NAME -n $NAMESPACE -- vault kv put secret/nextcloud-redis password=redis-secret
kubectl exec $POD_NAME -n $NAMESPACE -- vault kv put secret/minio accessKey=minioadmin secretKey=minioadmin
kubectl exec $POD_NAME -n $NAMESPACE -- vault kv put secret/nextcloud adminUser=admin adminPassword=adminpass
kubectl exec $POD_NAME -n $NAMESPACE -- vault policy write db-policy - <<EOF
path "secret/data/postgres" { capabilities = ["read"] }
path "secret/data/gitlab-redis" { capabilities = ["read"] }
path "secret/data/nextcloud-redis" { capabilities = ["read"] }
path "secret/data/minio" { capabilities = ["read"] }
path "secret/data/nextcloud" { capabilities = ["read"] }
EOF
kubectl exec $POD_NAME -n $NAMESPACE -- vault auth enable kubernetes
kubectl exec $POD_NAME -n $NAMESPACE -- vault write auth/kubernetes/config \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"
echo "Vault initialized! Secure vault-init.txt!"