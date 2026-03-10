# elasticsearch-curator-secure

Защищённая сборка **Elasticsearch Curator** на базе Astra Linux 1.8 с автоматическим сканированием CVE через [Trivy](https://github.com/aquasecurity/trivy).

## Статус

![Build & CVE Scan](https://github.com/OlegKarenkikh/elasticsearch-curator-secure/actions/workflows/build-and-scan.yml/badge.svg)

## Структура репозитория

```
.
├── Dockerfile                        # Multi-stage сборка, все уязвимые пакеты обновлены
├── requirements.txt                  # Python-зависимости с зафиксированными безопасными версиями
├── .trivyignore                      # Обоснованные исключения CVE
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

## Устранённые уязвимости

Основаны на отчёте `req-1159159` (сканирование 02.03.26):

### Python-пакеты
| Пакет | CVE | Исправлено |
|---|---|---|
| setuptools | CVE-2024-6345, CVE-2025-47273, CVE-2022-40897 | ≥78.1.1 |
| pip | CVE-2023-5752, CVE-2026-1703 | ≥26.0 |
| urllib3 | CVE-2025-50181, CVE-2025-66471, CVE-2026-21441 | ≥2.6.3 |
| wheel | CVE-2026-24049 | ≥0.46.2 |

### Системные пакеты (Astra 1.8)
| Пакет | CVE |
|---|---|
| openssl | CVE-2025-15467 (CRITICAL 9.8), CVE-2024-5535 |
| linux-libc-dev | Удалён из образа (~300+ CVE) |
| libkrb5 | CVE-2024-37371 (CRITICAL 9.1) |
| libnss3 | CVE-2024-6602 (CRITICAL 9.8) |
