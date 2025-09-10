# MinIO Chart
Custom Helm chart for MinIO object storage.

## Install
```bash
helm install minio ./charts/minio --namespace default --set vault.enabled=true

Values

image.repository: minio/minio
image.tag: RELEASE.2025-09-05T22-47-19Z
vault.enabled: true to use Vault secrets
persistence.size: 20Gi


