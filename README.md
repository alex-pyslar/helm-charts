High-Tech K8s Ecosystem: Postgres, Vault, GitLab, Redis, MinIO, Nextcloud
Это монопо-репозиторий с кастомными Helm-чартами для развёртывания полноценной экосистемы в Kubernetes. Проект построен на принципах модульности, безопасности и масштабируемости: PostgreSQL как общая БД, Vault для секретов, GitLab для CI/CD с Redis для кэширования, MinIO как S3-совместимое хранилище (для artifacts и бэкапов), и Nextcloud для облачного файлового хранилища с собственным Redis. Всё без внешних Helm-репозиториев — чистые, кастомные чарты на официальных Docker-образах.

Структура проекта
my-k8s-project/
├── .gitignore           # Игнор артефактов
├── README.md            # Этот файл
├── scripts/             # Bash-скрипты для управления
│   ├── common.sh        # Общие функции
│   ├── lint-all.sh      # Lint всех чартов
│   ├── template-all.sh  # Preview YAML
│   ├── install-all.sh   # Полный деплой
│   ├── upgrade-all.sh   # Обновление
│   ├── uninstall-all.sh # Удаление
│   └── vault-init.sh    # Инициализация Vault
├── integrations/        # Примеры интеграций
│   ├── postgres-vault-annotations.yaml  # Vault для Postgres
│   ├── gitlab-postgres-config.yaml      # GitLab с Postgres
│   ├── gitlab-redis-config.yaml         # GitLab с Redis
│   ├── gitlab-minio-config.yaml         # GitLab с MinIO
│   ├── postgres-minio-backup.yaml       # Бэкапы Postgres в MinIO
│   └── values-overrides/                # Overrides для env
│       ├── dev-values.yaml
│       └── prod-values.yaml
├── charts/              # Helm-чарты
│   ├── postgres/        # StatefulSet, Service, PVC, Secret
│   ├── vault/           # StatefulSet, Service, Injector
│   ├── redis/           # Deployment, Service, PVC (используется для GitLab и Nextcloud)
│   ├── minio/           # Deployment, Service, PVC
│   ├── gitlab/          # Deployment, Service, Ingress
│   └── nextcloud/       # Deployment, Service, PVC, Init-job
└── LICENSE              # Опционально, MIT

Требования

Kubernetes 1.28+ (EKS/GKE/AKS или minikube/kind для теста)
Helm 3.14+
Kubectl
StorageClass для dynamic PVC (e.g., standard)
Доступ к Docker Hub для образов (postgres:16-alpine, hashicorp/vault:1.15, gitlab/gitlab-ce:latest, redis:7.2-alpine, minio/minio:RELEASE.2025-09-05T22-47-19Z, nextcloud:apache)
Ресурсы кластера: минимум 8CPU/16GB для всех сервисов

Установка и деплой

Клонируй репо:
git clone your-repo.git
cd my-k8s-project


Настрой namespace (опционально):
export NAMESPACE=your-ns
kubectl create ns $NAMESPACE


Проверь чарты:
./scripts/lint-all.sh
./scripts/template-all.sh  # Вывод в tmp/


Разверни всё:
./scripts/install-all.sh

Это деплоит: Vault → MinIO → Postgres → Redis (для GitLab и Nextcloud) → GitLab → Nextcloud. Ждёт готовности подов.

Инициализируй Vault:
./scripts/vault-init.sh

Введи unseal keys, сохрани vault-init.txt в безопасном месте!

Доступ к сервисам (используй port-forward или Ingress):

Postgres: kubectl port-forward svc/postgres-postgres 5432:5432
Vault: kubectl port-forward svc/vault-vault 8200:8200
Redis (GitLab): kubectl port-forward svc/gitlab-redis-redis 6379:6379
Redis (Nextcloud): kubectl port-forward svc/nextcloud-redis-redis 6379:6379
MinIO: kubectl port-forward svc/minio-minio 9000:9000 (UI: localhost:9001, creds from Vault)
GitLab: kubectl port-forward svc/gitlab-gitlab 80:80 (root creds from GitLab UI)
Nextcloud: kubectl port-forward svc/nextcloud-nextcloud 80:80 (admin creds from Vault)



Конфигурация и интеграции

Overrides: Используй --values integrations/values-overrides/prod-values.yaml для prod (e.g., больше реплик).
Vault: Все секреты (пароли Postgres, Redis, MinIO, Nextcloud) в Vault. Чарты инжектят их через annotations.
GitLab: Интегрировано с Postgres (БД), Redis (кэш), MinIO (artifacts/LFS). Проверь CI/CD pipelines.
Nextcloud: Интегрировано с Postgres (отдельная DB), Redis (memcache/locking), MinIO (опционально для external storage). Auto-install на первый запуск.
Бэкапы: Postgres → MinIO через CronJob (см. integrations/postgres-minio-backup.yaml).

Troubleshooting

Поды не стартуют? Проверь logs: kubectl logs <pod-name> -c <container>.
Vault sealed? Повтори ./scripts/vault-init.sh.
No PVC? Убедись в StorageClass: kubectl get sc.
Секреты не инжектятся? Проверь Vault policy и injector pod.
Масштаб: Для HA добавь replicas в values.yaml (e.g., Redis Sentinel).

Расширение

Мониторинг: Добавь Prometheus/Grafana (новый чарт) для метрик.
TLS: Cert-Manager для HTTPS в Ingress.
CI/CD: Настрой GitLab runners для авто-деплоя.
GitOps: ArgoCD для declarative updates из этого репо.

Лицензия: MIT. Вопросы? Контрибьют в issues!