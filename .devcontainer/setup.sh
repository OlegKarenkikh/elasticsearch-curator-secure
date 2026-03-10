#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Trivy..."
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
  | sh -s -- -b /usr/local/bin

echo "==> Updating Trivy vulnerability database..."
trivy image --download-db-only

echo "==> Trivy version:"
trivy --version

echo "==> Verifying Docker..."
docker info --format 'Docker Engine {{.ServerVersion}}' 2>/dev/null || echo "Docker not ready yet"

echo ""
echo "================================================"
echo " Codespace ready! Chainguard-based secure build"
echo "------------------------------------------------"
echo "  make build          - build Docker image"
echo "  make scan           - Trivy: CRITICAL/HIGH/MEDIUM"
echo "  make scan-critical  - gate: exit 1 on any CVE"
echo "  make scan-json      - save full report to JSON"
echo "  make clean          - remove local image"
echo "  make help           - show all commands"
echo "================================================"
echo ""
echo "Base image : cgr.dev/chainguard/python:latest (0 CVE)"
echo "Scan basis : req-1159159 (Astra Linux 1.8, 02.03.2026 - 1133 CVE resolved)"
