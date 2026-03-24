# syntax=docker/dockerfile:1
# =================================================================
# Stage 1: builder — cgr.dev/chainguard/python:latest-dev
#   - содержит pip, shell, компилятор
#   - пересобирается ежедневно из исходников (Wolfi)
#   - 0 CVE на момент сборки
# =================================================================
FROM cgr.dev/chainguard/python:latest-dev AS builder

WORKDIR /app

COPY requirements.txt .

# Обновить базовые pip-инструменты и установить зависимости
# в изолированную директорию /app/packages
RUN pip install --no-cache-dir --upgrade pip setuptools wheel \
    && pip install --no-cache-dir --target=/app/packages -r requirements.txt

# =================================================================
# Stage 2: runtime — cgr.dev/chainguard/python:latest
#   - нет shell, нет pip, нет лишних пакетов
#   - 0 CVE, встроенный SBOM + Sigstore-подпись
#   - non-root по умолчанию (uid=65532)
# =================================================================
FROM cgr.dev/chainguard/python:latest

WORKDIR /app

# Копируем только установленные пакеты из builder
COPY --from=builder /app/packages /app/packages

# Указываем Python путь к пакетам
ENV PYTHONPATH=/app/packages

# Chainguard runtime не имеет shell (/bin/sh отсутствует).
# pip install --target НЕ создаёт bin-скрипты (console_scripts),
# поэтому вызываем cli-функцию напрямую через -c.
# curator.cli:cli — официальная точка входа пакета (console_scripts в pyproject.toml).
ENTRYPOINT ["/usr/bin/python", "-c", "from curator.cli import cli; cli()"]
CMD ["--help"]
