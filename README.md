# elasticsearch-curator-secure

Защищённая сборка **Elasticsearch Curator** на базе [Chainguard Python](https://edu.chainguard.dev/chainguard/chainguard-images/reference/python/) (zero-CVE) с автоматическим сканированием через [Trivy](https://github.com/aquasecurity/trivy).

## Статус

![Build & CVE Scan](https://github.com/OlegKarenkikh/elasticsearch-curator-secure/actions/workflows/build-and-scan.yml/badge.svg)

## Базовый образ

| Слой | Образ | CVE |
|---|---|---|
| Builder | `cgr.dev/chainguard/python:latest-dev` | 0 |
| Runtime | `cgr.dev/chainguard/python:latest` | 0 |

Chainguard-образы основаны на **Wolfi** (musl libc + apk) и пересобираются ежедневно.
Каждый образ содержит встроенный SBOM и Sigstore-подпись. Публичный pull без авторизации.

## Структура репозитория

```
.
├── Dockerfile                        # Multi-stage: chainguard/python:dev → chainguard/python
├── requirements.txt                  # Python-зависимости с зафиксированными безопасными версиями
├── .trivyignore                      # Шаблон обоснованных исключений CVE
├── Makefile                          # make build / scan / scan-critical / scan-json
├── .devcontainer/
│   ├── devcontainer.json             # GitHub Codespaces конфигурация
│   └── setup.sh                      # Автоустановка Trivy в Codespaces
└── .github/workflows/
    └── build-and-scan.yml            # CI: сборка → Trivy → SARIF → gate
```

## Быстрый старт (Codespaces)

1. Нажать **Code → Open with Codespaces** в GitHub
2. После инициализации (`setup.sh`) Trivy уже доступен
3. Запустить сборку и сканирование:

```bash
make scan-critical   # Сборка + проверка CRITICAL/HIGH, exit 1 при наличии CVE
make scan            # Полный отчёт CRITICAL/HIGH/MEDIUM
make scan-json       # Сохранить отчёт в trivy-results.json
```

## CI/CD Pipeline

| Шаг | Описание |
|---|---|
| `Build` | `docker buildx build` с GHA cache |
| `Trivy Table` | Вывод в лог PR |
| `Trivy SARIF` | Загрузка в **Security → Code scanning** |
| `Trivy JSON` | Артефакт 30 дней |
| `Gate` | `exit-code: 1` блокирует merge при CRITICAL/HIGH |
| `Schedule` | Ежедневная проверка новых CVE в 03:00 UTC |

## Почему Chainguard, а не debian:slim / distroless?

| | `python:3.11-slim` | `distroless/python3` | **Chainguard python** |
|---|---|---|---|
| CVE | ~80–150 | ~0 (сканер не видит) | **0 (реально)** |
| SBOM | ❌ | ❌ | ✅ встроен |
| Sigstore-подпись | ❌ | ❌ | ✅ |
| Shell в runtime | ✅ | ❌ | ❌ |
| non-root by default | ❌ | ✅ | ✅ (uid 65532) |
| Публичный pull | ✅ | ✅ | ✅ |
| Размер | ~130 MB | ~34 MB | ~55 MB |

## Устранённые уязвимости (отчёт req-1159159)

Смена базового образа Astra Linux 1.8 → Chainguard Python устраняет все 1133 CVE:

| Пакет | CVE | CVSS3 |
|---|---|---|
| openssl | CVE-2025-15467 | 9.8 CRITICAL |
| linux-libc-dev | CVE-2024-38623, CVE-2024-38612 | 9.8 CRITICAL |
| libkrb5 | CVE-2024-37371 | 9.1 CRITICAL |
| libnss3 | CVE-2024-6602 | 9.8 CRITICAL |
| libabsl | CVE-2025-0838 | 9.8 CRITICAL |
| setuptools | CVE-2024-6345, CVE-2025-47273 | 8.8 HIGH |
| urllib3 | CVE-2025-66471, CVE-2026-21441 | 7.5 HIGH |
