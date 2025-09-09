#!/bin/bash
source ./scripts/common.sh
check_tools

mkdir -p tmp
for chart in $CHARTS_DIR/*; do
    echo "Templating $chart..."
    helm template my-release $chart > tmp/$(basename $chart)-template.yaml
done
echo "Templates generated in tmp/!"