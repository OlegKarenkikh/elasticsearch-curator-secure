# Security Policy

## Base Image

This project uses **Chainguard Python** (`cgr.dev/chainguard/python`) - a zero-CVE image
rebuilt daily from source based on Wolfi OS.

## Automated Scanning

Every commit and PR is automatically scanned by **Trivy** in GitHub Actions:

- Results visible in **Security -> Code scanning** tab
- Merge to `main` blocked on unpatched CRITICAL or HIGH CVEs
- Daily cron at 03:00 UTC checks for new CVEs without a push event
- JSON report saved as artifact for 30 days per run

## Reporting a Vulnerability

If you discover a vulnerability in this project:

1. Do not create a public Issue
2. Use **Security -> Report a vulnerability** in GitHub
3. Or open a Discussion with details

We aim to respond within 72 hours.

## Base Image History

| Date | Image | CVE count |
|---|---|---|
| 10.03.2026 - present | cgr.dev/chainguard/python:latest | 0 |
| before 10.03.2026 | registry.astralinux.ru/astra/ce/alse:1.8 | 1133 |

Original scan report: req-1159159 (02.03.2026)

## CVE Sources

- https://edu.chainguard.dev/chainguard/chainguard-images/reference/python/
- https://trivy.dev/
- https://nvd.nist.gov/
