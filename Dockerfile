# n8n "full" sobre Node Alpine + Chromium + ffmpeg
# Base garantizada con apk disponible
FROM node:20-alpine

# 1) Dependencias del sistema (Chromium + fonts + libs típicas para headless)
RUN apk add --no-cache \
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

# 2) Variables para Puppeteer/Chromium (Alpine suele usar /usr/bin/chromium)
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV CHROME_BIN=/usr/bin/chromium
ENV CHROMIUM_PATH=/usr/bin/chromium

# 3) Variables mínimas de n8n para correr bien en contenedor
ENV NODE_ENV=production
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=http
ENV N8N_USER_FOLDER=/home/node/.n8n

# 4) Instalar n8n (mejor fijar versión para evitar sorpresas)
# Si querés, cambiá 1.0.0 por la versión que uses (recomendado)
RUN npm install -g n8n@latest

# 5) Preparar persistencia (esto es CLAVE para que tus workflows queden en volumen)
RUN mkdir -p /home/node/.n8n /data && \
    chown -R node:node /home/node/.n8n /data

# 6) Usuario no-root
USER node

# 7) Exponer puerto
EXPOSE 5678

# 8) Iniciar n8n
CMD ["n8n"]
