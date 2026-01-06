# n8n "Full Power" sobre Node Alpine
FROM node:20-alpine

# 1) Instalar TODAS las dependencias del sistema
# - git: CRUCIAL para instalar community nodes (soluciona tu error anterior)
# - chromium & deps: Para Puppeteer
# - ffmpeg: Para audio/video
# - graphicsmagick: Para el nodo de manipulación de imágenes de n8n
# - tzdata: Para configurar la zona horaria correctamente
# - curl, bash, jq: Herramientas útiles para scripts en n8n
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

# 2) Variables de entorno para Puppeteer
# Le decimos que NO descargue su propio Chromium, que use el de Alpine
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV CHROME_BIN=/usr/bin/chromium
ENV CHROMIUM_PATH=/usr/bin/chromium

# 3) Variables de entorno de n8n
ENV NODE_ENV=production
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=http
# IMPORTANTE: Definir la Timezone por defecto (cambiala si no sos de Argentina)
ENV TZ=America/Argentina/Buenos_Aires

# 4) Instalar n8n globalmente
# Te sugiero fuertemente instalar una versión fija para estabilidad, pero dejo latest si preferís
RUN npm install -g n8n@latest

# 5) Crear directorio de trabajo y asignar permisos
# Creamos la carpeta .n8n explícitamente y asignamos dueño al usuario 'node'
WORKDIR /home/node
RUN mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node/.n8n

# 6) Cambiar al usuario sin privilegios
USER node

# 7) Exponer el puerto
EXPOSE 5678

# 8) Comando de inicio
CMD ["n8n"]
