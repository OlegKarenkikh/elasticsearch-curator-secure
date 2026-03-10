# syntax=docker/dockerfile:1
# ============================================================
# Stage 1: builder — обновление deb-пакетов и Python-зависимостей
# ============================================================
FROM registry.astralinux.ru/astra/ce/alse:1.8 AS builder

ARG CURATOR_VERSION=8.0.16

# Обновить уязвимые системные пакеты
RUN apt-get update && apt-get upgrade -y --no-install-recommends \
        openssl libssl3 \
        libkrb5-3 libgssapi-krb5-2 libk5crypto3 libkrb5support0 \
        libnss3 \
        libgnutls30 \
        libexpat1 \
        curl libcurl4 \
        xz-utils liblzma5 \
        gnupg gpg gpg-agent gpgsm gpgv gpgconf \
        python3.11 libpython3.11 libpython3.11-minimal libpython3.11-stdlib \
        libc6 \
    && apt-get remove -y --purge \
        linux-libc-dev \
        libssl-dev libpng-dev libfreetype-dev \
        libheif-dev libxml2-dev libexpat1-dev \
        liblzma-dev \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Обновить pip/setuptools/wheel/urllib3 до версий без CVE
RUN pip3 install --no-cache-dir --upgrade \
    "pip>=26.0" \
    "setuptools>=78.1.1" \
    "wheel>=0.46.2" \
    "urllib3>=2.6.3" \
    "jaraco.context>=6.1.0"

# Установить curator
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

# ============================================================
# Stage 2: final — минимальный runtime-образ
# ============================================================
FROM registry.astralinux.ru/astra/ce/alse:1.8 AS final

COPY --from=builder /usr/lib/python3 /usr/lib/python3
COPY --from=builder /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY --from=builder /usr/local/bin/curator /usr/local/bin/curator

# Обновить только runtime-пакеты в финальном образе
RUN apt-get update && apt-get upgrade -y --no-install-recommends \
        openssl libssl3 \
        libkrb5-3 libgssapi-krb5-2 libk5crypto3 libkrb5support0 \
        libnss3 libgnutls30 libexpat1 \
        curl libcurl4 xz-utils liblzma5 \
        python3.11 libpython3.11 libpython3.11-minimal libpython3.11-stdlib \
        libc6 \
    && apt-get remove -y --purge linux-libc-dev \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

USER 1000:1000

ENTRYPOINT ["/usr/local/bin/curator"]
CMD ["--help"]
