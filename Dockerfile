FROM node:20-alpine

# ---------------------------------------------------------------------------
# 1. INSTALACIÓN DE DEPENDENCIAS (Limpieza de conflictos)
# ---------------------------------------------------------------------------
# Instalamos lo necesario para Chromium, compilar nativos (build-base) y manejo de imágenes
RUN apk add --no-cache \
    git \
    bash \
    curl \
    jq \
    tzdata \
    graphicsmagick \
    ffmpeg \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    font-noto-emoji \
    python3 \
    make \
    g++ \
    build-base \
    cairo \
    pango \
    libjpeg-turbo \
    libpng \
    udev \
    sudo \
    shadow

# ---------------------------------------------------------------------------
# 2. VARIABLES DE ENTORNO
# ---------------------------------------------------------------------------
ENV NODE_FUNCTION_ALLOW_EXTERNAL=*
ENV NODE_PATH=/usr/local/lib/node_modules
ENV TZ=America/Argentina/Buenos_Aires

# Variables Puppeteer / Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV CHROME_BIN=/usr/bin/chromium
ENV CHROMIUM_PATH=/usr/bin/chromium

# Variables n8n
ENV NODE_ENV=production
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=http

# ---------------------------------------------------------------------------
# 3. INSTALACIÓN DE N8N Y LIBRERÍAS GLOBALES
# ---------------------------------------------------------------------------
# Usamos puppeteer-core para no bajar otro chrome.
# Instalamos n8n y las librerías extra que pediste.
RUN npm install -g n8n@latest puppeteer-core axios cheerio moment lodash date-fns jimp sharp

# ---------------------------------------------------------------------------
# 4. PREPARACIÓN DE DIRECTORIOS Y PERMISOS
# ---------------------------------------------------------------------------
WORKDIR /home/node

# Preparamos carpetas y damos permisos amplios para evitar errores de EACCES
RUN mkdir -p /home/node/.n8n /data && \
    chown -R node:node /home/node && \
    chmod -R 777 /home/node /data

# Configuración de sudo para el usuario node (sin contraseña)
RUN echo "node ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ---------------------------------------------------------------------------
# 5. SCRIPT DE ARRANQUE (Sin sintaxis heredoc para compatibilidad)
# ---------------------------------------------------------------------------
# Creamos el script start.sh de forma tradicional con echo
RUN echo '#!/bin/bash' > /usr/local/bin/start-n8n.sh && \
    echo 'set -e' >> /usr/local/bin/start-n8n.sh && \
    echo 'CURRENT_USER=$(whoami)' >> /usr/local/bin/start-n8n.sh && \
    echo 'echo "Iniciando n8n como: $CURRENT_USER"' >> /usr/local/bin/start-n8n.sh && \
    echo 'if [ "$CURRENT_USER" = "root" ]; then' >> /usr/local/bin/start-n8n.sh && \
    echo '  export N8N_USER_FOLDER=/home/node/.n8n' >> /usr/local/bin/start-n8n.sh && \
    echo '  # Si somos root, arreglamos permisos al vuelo por si se montó un volumen externo' >> /usr/local/bin/start-n8n.sh && \
    echo '  chown -R node:node /home/node/.n8n /data' >> /usr/local/bin/start-n8n.sh && \
    echo 'else' >> /usr/local/bin/start-n8n.sh && \
    echo '  export N8N_USER_FOLDER=/home/node/.n8n' >> /usr/local/bin/start-n8n.sh && \
    echo 'fi' >> /usr/local/bin/start-n8n.sh && \
    echo 'exec n8n' >> /usr/local/bin/start-n8n.sh && \
    chmod +x /usr/local/bin/start-n8n.sh

# ---------------------------------------------------------------------------
# 6. EJECUCIÓN
# ---------------------------------------------------------------------------
EXPOSE 5678

# Arrancamos como usuario node por defecto, pero permite ser sobreescrito
USER node
CMD ["/usr/local/bin/start-n8n.sh"]
