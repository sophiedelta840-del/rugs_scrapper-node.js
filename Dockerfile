FROM node:20-slim AS builder

WORKDIR /app

# Copy package files and install all dependencies (including devDependencies for TypeScript)
COPY package*.json ./
RUN npm install

# Copy source and compile TypeScript
COPY . .
RUN npx tsc

# --- Production stage ---
FROM node:20-slim

# Install Chromium and dependencies
RUN apt-get update && apt-get install -y \
    chromium \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files and install production dependencies only
COPY package*.json ./
ENV PUPPETEER_SKIP_DOWNLOAD=true
RUN npm install --omit=dev

# Copy compiled JavaScript from builder
COPY --from=builder /app/dist ./dist

# Set Chromium executable path for puppeteer
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

CMD ["node", "dist/index.js"]

