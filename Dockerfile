# Base sólida de Node Alpine
FROM node:20-alpine

# ---------------------------------------------------------------------------
# 1. INSTALACIÓN MASIVA DE DEPENDENCIAS
# ---------------------------------------------------------------------------
RUN apk add --no-cache \
    git \
    bash \
    curl \
    jq \
    tzdata \
    graphicsmagick \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    font-noto \
    font-noto-emoji \
    fontconfig \
    python3 \
    py3-pip \
    make \
    g++ \
    build-base \
    cairo \
    pango \
    libjpeg-turbo \
    libpng \
    udev \
    ffmpeg \
    dumb-init

# ---------------------------------------------------------------------------
# 2. VARIABLES DE ENTORNO
# ---------------------------------------------------------------------------
ENV NODE_FUNCTION_ALLOW_EXTERNAL=*
ENV NODE_PATH=/usr/local/lib/node_modules

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROMIUM_PATH=/usr/bin/chromium-browser

ENV NODE_ENV=production
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=http
ENV TZ=America/Argentina/Buenos_Aires

# ---------------------------------------------------------------------------
# 3. INSTALACIÓN DE N8N Y LIBRERÍAS
# ---------------------------------------------------------------------------
RUN npm install -g n8n@2.2.4 puppeteer-core@24.10.2

# Compat symlink /usr/bin/chromium (por si tu código lo usa)
RUN if [ ! -f /usr/bin/chromium ] && [ -f /usr/bin/chromium-browser ]; then ln -s /usr/bin/chromium-browser /usr/bin/chromium; fi

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
