FROM n8nio/n8n:latest

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    # Base y seguridad
    ca-certificates \
    tzdata \
    gnupg \
    openssl \
    \
    # Networking y debugging
    curl \
    wget \
    git \
    openssh-client \
    iputils-ping \
    netcat-openbsd \
    dnsutils \
    \
    # Procesamiento de datos / archivos
    jq \
    unzip \
    zip \
    tar \
    gzip \
    bzip2 \
    xz-utils \
    \
    # Python
    python3 \
    python3-pip \
    \
    # Build tools
    build-essential \
    make \
    g++ \
    \
    # Imágenes
    imagemagick \
    \
    # Audio / Video
    ffmpeg \
    \
    # Chromium + deps Puppeteer
    chromium \
    fonts-liberation \
    fonts-dejavu-core \
    fonts-noto \
    fonts-noto-color-emoji \
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
    \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

USER node
