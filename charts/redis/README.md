# Redis Chart
Custom Helm chart for Redis, used by GitLab.

## Install
```bash
helm install redis ./charts/redis --namespace default --set vault.enabled=true

Values

image.repository: redis
image.tag: 7.2-alpine
vault.enabled: true to use Vault secrets
persistence.size: 1Gi