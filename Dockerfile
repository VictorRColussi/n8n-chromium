# Base sólida de Node Alpine
FROM node:20-alpine

# ---------------------------------------------------------------------------
# 1. INSTALACIÓN MASIVA DE DEPENDENCIAS
# ---------------------------------------------------------------------------
# - git: para instalar nodos de la comunidad
# - chromium & deps: para Puppeteer (todos los drivers gráficos necesarios)
# - ffmpeg: para audio/video
# - graphicsmagick: para manipulación de imágenes
# - build tools: python, make, g++ (para compilar cualquier cosa que falte)
# - utils: bash, curl, jq, tzdata (para scripts y zona horaria)
# + fontconfig: mejora render de fuentes
# + wkhtmltopdf: alternativa simple HTML->PDF sin puppeteer
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
    wkhtmltopdf

# ---------------------------------------------------------------------------
# 2. VARIABLES DE ENTORNO "HARDCODED" (PARA LIBERAR TODO)
# ---------------------------------------------------------------------------
# Permitir importar CUALQUIER librería en el nodo Code
ENV NODE_FUNCTION_ALLOW_EXTERNAL=*

# Decirle a Node que busque las librerías en la carpeta global
ENV NODE_PATH=/usr/local/lib/node_modules

# Configuración de Puppeteer para que use el Chromium de Alpine
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
# Alpine suele exponer chromium como /usr/bin/chromium-browser (y a veces /usr/bin/chromium)
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROMIUM_PATH=/usr/bin/chromium-browser

# Configuración básica de n8n
ENV NODE_ENV=production
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=http
# Zona horaria
ENV TZ=America/Argentina/Buenos_Aires

# ---------------------------------------------------------------------------
# 3. INSTALACIÓN DE N8N Y LIBRERÍAS
# ---------------------------------------------------------------------------
# Instalamos n8n y puppeteer-core GLOBALMENTE
# IMPORTANTÍSIMO: puppeteer-core@19 rompe en Node 20 (tu error actual).
RUN npm install -g n8n@2.2.4 puppeteer-core@24.10.2

# ---------------------------------------------------------------------------
# 3.1. COMPAT: aseguramos symlink /usr/bin/chromium por si tu código lo usa
# ---------------------------------------------------------------------------
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
CMD ["n8n"]
