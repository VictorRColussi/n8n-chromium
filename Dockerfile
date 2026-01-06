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
    ffmpeg

# ---------------------------------------------------------------------------
# 2. VARIABLES DE ENTORNO "HARDCODED" (PARA LIBERAR TODO)
# ---------------------------------------------------------------------------
# ESTO ES LO QUE TE FALTABA: Permitir importar CUALQUIER librería en el nodo Code
ENV NODE_FUNCTION_ALLOW_EXTERNAL=*

# Decirle a Node que busque las librerías en la carpeta global (donde instalamos puppeteer-core)
ENV NODE_PATH=/usr/local/lib/node_modules

# Configuración de Puppeteer para que use el Chromium de Alpine
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV CHROME_BIN=/usr/bin/chromium
ENV CHROMIUM_PATH=/usr/bin/chromium

# Configuración básica de n8n
ENV NODE_ENV=production
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=http
# Zona horaria (ajustala si no es Argentina)
ENV TZ=America/Argentina/Buenos_Aires

# ---------------------------------------------------------------------------
# 3. INSTALACIÓN DE N8N Y LIBRERÍAS
# ---------------------------------------------------------------------------
# Instalamos n8n y puppeteer-core GLOBALMENTE
RUN npm install -g n8n@latest puppeteer-core

# ---------------------------------------------------------------------------
# 4. PREPARACIÓN DE DIRECTORIOS
# ---------------------------------------------------------------------------
WORKDIR /home/node
# Creamos las carpetas y asignamos permisos al usuario node
RUN mkdir -p /home/node/.n8n /data && \
    chown -R node:node /home/node/.n8n /data

# ---------------------------------------------------------------------------
# 5. ARRANQUE
# ---------------------------------------------------------------------------
# Cambiamos a usuario node (root no es necesario para correr, solo para instalar)
USER node

EXPOSE 5678
CMD ["n8n"]
