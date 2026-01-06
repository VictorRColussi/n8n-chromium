# Dockerfile - n8n + Chromium + ffmpeg + utilidades (Debian)
# Compatible con apt-get (para que puedas instalar dependencias)

FROM n8nio/n8n:latest-debian

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    tzdata \
    gnupg \
    openssl \
    \
    curl \
    wget \
    git \
    openssh-client \
    iputils-ping \
    netcat-openbsd \
    dnsutils \
    \
    jq \
    unzip \
    zip \
    tar \
    gzip \
    bzip2 \
    xz-utils \
    \
    python3 \
    python3-pip \
    \
    build-essential \
    make \
    g++ \
    \
    imagemagick \
    \
    ffmpeg \
    \
    chromium \
    \
    fonts-liberation \
    fonts-dejavu-core \
    fonts-noto \
    fonts-noto-color-emoji \
    \
    libnss3 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    libpangocairo-1.0-0 \
    libpango-1.0-0 \
    libgtk-3-0 \
    libxshmfence1 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Evitar que Puppeteer descargue Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Rutas típicas en Debian
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV CHROME_BIN=/usr/bin/chromium
ENV CHROMIUM_PATH=/usr/bin/chromium

# n8n escucha en 0.0.0.0 dentro del contenedor
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678

USER node

EXPOSE 5678
# No definimos CMD/ENTRYPOINT: heredamos los del image base de n8n
