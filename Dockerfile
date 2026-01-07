# Base sólida de Node Debian (Bullseye)
FROM node:20-bullseye

# ---------------------------------------------------------------------------
# 1. INSTALACIÓN MASIVA DE DEPENDENCIAS
# ---------------------------------------------------------------------------
# - chromium: navegador
# - fonts: para PDFs bien renderizados
# - librerías X/GTK/NSS: necesarias para headless chrome
# - dumb-init: init correcto para contenedores (señales, zombies)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    bash \
    curl \
    jq \
    tzdata \
    graphicsmagick \
    chromium \
    ca-certificates \
    fontconfig \
    fonts-freefont-ttf \
    fonts-noto \
    fonts-noto-color-emoji \
    python3 \
    python3-pip \
    make \
    g++ \
    libcairo2 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libjpeg62-turbo \
    libpng16-16 \
    udev \
    ffmpeg \
    dumb-init \
    # deps típicas de chromium headless
    libnss3 \
    libx11-6 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libxss1 \
    libxtst6 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libgtk-3-0 \
    libgbm1 \
    libasound2 \
    xdg-utils \
 && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# 2. VARIABLES DE ENTORNO
# ---------------------------------------------------------------------------
ENV NODE_FUNCTION_ALLOW_EXTERNAL=*
ENV NODE_PATH=/usr/local/lib/node_modules

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
# Debian: normalmente chromium vive acá
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV CHROME_BIN=/usr/bin/chromium
ENV CHROMIUM_PATH=/usr/bin/chromium

ENV NODE_ENV=production
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=http
ENV TZ=America/Argentina/Buenos_Aires

# ---------------------------------------------------------------------------
# 3. INSTALACIÓN DE N8N Y LIBRERÍAS
# ---------------------------------------------------------------------------
RUN npm install -g n8n@2.2.4 puppeteer-core@24.10.2

# Compat: symlink /usr/bin/chromium-browser por si tu código lo usa
RUN if [ ! -f /usr/bin/chromium-browser ] && [ -f /usr/bin/chromium ]; then ln -s /usr/bin/chromium /usr/bin/chromium-browser; fi

# ---------------------------------------------------------------------------
# 4. PREPARACIÓN DE DIRECTORIOS
# ---------------------------------------------------------------------------
WORKDIR /home/node
RUN mkdir -p /home/node/.n8n /data && \
    chown -R node:node /home/node/.n8n /data

# ---------------------------------------------------------------------------
# 5. ARRANQUE
# ---------------------------------------------------------------------------
USER node
EXPOSE 5678

ENTRYPOINT ["dumb-init", "--"]
CMD ["n8n"]
