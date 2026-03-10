#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Trivy..."
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
  | sh -s -- -b /usr/local/bin

echo "==> Updating Trivy vulnerability DB..."
trivy image --download-db-only

echo "==> Trivy version:"
trivy --version

echo ""
echo "========================================"
echo " Codespaces ready! Useful commands:"
echo "  make build        — собрать образ"
echo "  make scan         — сканировать Trivy"
echo "  make scan-critical — только CRITICAL/HIGH"
echo "========================================"
