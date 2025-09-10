   #!/bin/bash
   export NAMESPACE=${NAMESPACE:-default}
   export RELEASE_VAULT=vault
   export RELEASE_POSTGRES=postgres
   export RELEASE_GITLAB=gitlab
   export CHARTS_DIR="$(dirname "$0")/../charts"

   check_tools() {
       command -v kubectl >/dev/null 2>&1 || { echo "kubectl is required"; exit 1; }
       command -v helm >/dev/null 2>&1 || { echo "helm is required"; exit 1; }
       echo "Tools check passed!"
   }