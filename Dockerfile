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
    chromium-chromedriver \
    nss \
    freetype \
    freetype-dev \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    font-noto \
    font-noto-emoji \
    wqy-zenhei \
    python3 \
    py3-pip \
    make \
    g++ \
    gcc \
    build-base \
    cairo \
    cairo-dev \
    pango \
    pango-dev \
    libjpeg-turbo \
    libjpeg-turbo-dev \
    libpng \
    libpng-dev \
    giflib-dev \
    pixman-dev \
    pangomm-dev \
    libjpeg \
    udev \
    ttf-liberation \
    libx11 \
    libxcomposite \
    libxcursor \
    libxdamage \
    libxi \
    libxtst \
    cups-libs \
    libxss \
    libxrandr \
    alsa-lib \
    at-spi2-atk \
    at-spi2-core \
    atk \
    dbus-libs \
    sudo \
    ffmpeg

# ---------------------------------------------------------------------------
# 2. VARIABLES DE ENTORNO UNIVERSALES
# ---------------------------------------------------------------------------
ENV NODE_FUNCTION_ALLOW_EXTERNAL=*
ENV NODE_PATH=/usr/local/lib/node_modules

# Configuración de Puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROMIUM_PATH=/usr/bin/chromium-browser

# Configuración básica de n8n
ENV NODE_ENV=production
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=http
ENV TZ=America/Argentina/Buenos_Aires

# Variables para Chromium
ENV CHROME_DEVEL_SANDBOX=/usr/lib/chromium/chrome-sandbox
ENV PUPPETEER_DISABLE_DEV_SHM_USAGE=true

# ---------------------------------------------------------------------------
# 3. INSTALACIÓN DE N8N Y LIBRERÍAS
# ---------------------------------------------------------------------------
RUN npm install -g n8n@latest puppeteer

# Instalar librerías adicionales útiles
RUN npm install -g \
    axios \
    cheerio \
    moment \
    lodash \
    date-fns \
    sharp \
    jimp

# ---------------------------------------------------------------------------
# 4. CONFIGURACIÓN UNIVERSAL DE PERMISOS
# ---------------------------------------------------------------------------
WORKDIR /home/node

# Crear directorios para AMBOS usuarios (root y node)
RUN mkdir -p /home/node/.n8n /root/.n8n /data && \
    chown -R node:node /home/node && \
    chmod -R 777 /home/node/.n8n /root/.n8n /data

# Dar permisos al chrome-sandbox para que funcione con cualquier usuario
RUN chmod 4755 /usr/lib/chromium/chrome-sandbox

# Dar privilegios sudo al usuario node (por si acaso)
RUN echo "node ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ---------------------------------------------------------------------------
# 5. SCRIPT DE INICIO INTELIGENTE
# ---------------------------------------------------------------------------
# Este script detecta automáticamente si sos root o no
COPY <<'EOF' /usr/local/bin/start-n8n.sh
#!/bin/bash
set -e

# Detectar el usuario actual
CURRENT_USER=$(whoami)

echo "=========================================="
echo "Iniciando n8n como usuario: $CURRENT_USER"
echo "=========================================="

# Configurar el directorio de n8n según el usuario
if [ "$CURRENT_USER" = "root" ]; then
    export N8N_USER_FOLDER=/root/.n8n
    echo "Modo: ROOT - Todos los permisos disponibles"
else
    export N8N_USER_FOLDER=/home/node/.n8n
    echo "Modo: NON-ROOT - Usuario estándar"
fi

# Asegurar que el directorio existe y tiene permisos
mkdir -p $N8N_USER_FOLDER
chmod -R 777 $N8N_USER_FOLDER 2>/dev/null || true

echo "Directorio de datos: $N8N_USER_FOLDER"
echo "=========================================="

# Iniciar n8n
exec n8n
EOF

# Hacer el script ejecutable
RUN chmod +x /usr/local/bin/start-n8n.sh

# ---------------------------------------------------------------------------
# 6. EXPONEMOS EL PUERTO
# ---------------------------------------------------------------------------
EXPOSE 5678

# ---------------------------------------------------------------------------
# 7. ARRANQUE UNIVERSAL (funciona como root o como node)
# ---------------------------------------------------------------------------
# NO especificamos USER, dejamos que Docker decida en runtime
CMD ["/usr/local/bin/start-n8n.sh"]
