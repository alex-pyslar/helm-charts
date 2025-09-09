Postgres Chart
Custom Helm chart for PostgreSQL.
Install
helm install postgres ./charts/postgres --namespace default --set vault.enabled=true

Values

image.repository: postgres
image.tag: 16-alpine
vault.enabled: true to use Vault secrets
persistence.size: 10Gi
