#!/bin/bash
source ./scripts/common.sh
check_tools

for chart in $CHARTS_DIR/*; do
    echo "Linting $chart..."
    helm lint $chart
done
echo "All charts linted successfully!"