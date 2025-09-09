My K8s Project
Монопо для развёртывания PostgreSQL, Vault и GitLab в Kubernetes через Helm. Всё кастомное, без внешних репозиториев.
Требования

Helm 3+
Kubectl
Kubernetes (minikube/kind для локального тестирования)
Docker images: postgres:16-alpine, hashicorp/vault:1.15, gitlab/gitlab-ce:latest

Установка

Инициализация Git: git init
Разверни всё: ./scripts/install-all.sh
Инициализация Vault: ./scripts/vault-init.sh
Доступ:
PostgreSQL: kubectl port-forward svc/postgres 5432:5432
Vault: kubectl port-forward svc/vault 8200:8200
GitLab: Check kubectl get svc gitlab



Управление

Lint: ./scripts/lint-all.sh
Preview: ./scripts/template-all.sh
Upgrade: ./scripts/upgrade-all.sh
Uninstall: ./scripts/uninstall-all.sh

Интеграции

PostgreSQL использует Vault для секретов (via sidecar injector).
GitLab использует PostgreSQL как backend (see integrations/gitlab-postgres-config.yaml).

Overrides

Dev: --values integrations/values-overrides/dev-values.yaml
Prod: --values integrations/values-overrides/prod-values.yaml
