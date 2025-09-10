# Nextcloud Chart
Custom Helm chart for Nextcloud with Postgres and Redis.

## Install
```bash
helm install nextcloud ./charts/nextcloud --namespace default --set vault.enabled=true

Values

image.repository: nextcloud
image.tag: apache
vault.enabled: true to use Vault secrets
persistence.size: 50Gi
postgres.host: existing Postgres service
redis.host: nextcloud-redis service