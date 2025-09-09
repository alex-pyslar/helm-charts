Vault Chart
Custom Helm chart for HashiCorp Vault.
Install
helm install vault ./charts/vault --namespace default
./scripts/vault-init.sh

Values

image.repository: hashicorp/vault
image.tag: 1.15
server.ha.enabled: false
