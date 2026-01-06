# Dockerfile - n8n + Chromium + herramientas esenciales (Alpine)
# Listo para copiar/pegar en tu repo (raíz del proyecto)

FROM n8nio/n8n:latest

# Cambiamos a root para instalar paquetes
USER root

# Instalar herramientas + Chromium y dependencias típicas para Puppeteer/Playwright
RUN apk add --no-cache \
  ca-certificates tzdata gnupg openssl \
  curl wget git openssh-client \
  iputils bind-tools netcat-openbsd \
  jq unzip zip tar gzip bzip2 xz \
  python3 py3-pip \
  build-base make g++ \
  imagemagick \
  ffmpeg \
  chromium \
  nss \
  atk \
  at-spi2-atk \
  cups-libs \
  mesa-dri-gallium \
  libxcomposite \
  libxdamage \
  libxrandr \
  libxkbcommon \
  alsa-lib \
  pango \
  cairo \
  gtk+3.0 \
  libdrm \
  libgbm \
  libxshmfence \
  harfbuzz \
  freetype \
  ttf-dejavu \
  font-noto \
  font-noto-emoji \
  dumb-init

# Evitar que Puppeteer intente descargar Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Rutas típicas en Alpine (dejamos ambas por compatibilidad)
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV CHROME_BIN=/usr/bin/chromium
ENV CHROMIUM_PATH=/usr/bin/chromium

# n8n escucha en 0.0.0.0 dentro del contenedor
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678

# Asegurar permisos y volver a usuario node (recomendado por n8n)
USER node

# Exponer el puerto de n8n (Coolify/Traefik lo detecta)
EXPOSE 5678

# Mantener entrypoint/command del image base (n8n)

