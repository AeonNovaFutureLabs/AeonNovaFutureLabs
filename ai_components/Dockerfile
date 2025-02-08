# ----------------------------------------------------------------------------
# File: Dockerfile
# Location: /Volumes/mattstack/VSCode/AeonNovaFutureLabs/ai_components/
#
# Purpose: Docker image for AI components including chat scraper
# Security Level: Confidential
# Owner: Infrastructure Team
# Version: 1.0
# Last Modified: 2025-02-08
# ----------------------------------------------------------------------------

# Build stage for TypeScript components
FROM node:18-slim AS ts-builder
WORKDIR /app
COPY scraper/package*.json ./scraper/
RUN cd scraper && npm install
COPY scraper/ ./scraper/
RUN cd scraper && npm run build

# Build stage for Python components
FROM python:3.8-slim AS py-builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
RUN python -m compileall .

# Final stage
FROM python:3.8-slim
WORKDIR /app

# Install Node.js
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome for Puppeteer
RUN apt-get update && apt-get install -y \
    chromium \
    chromium-driver \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set Puppeteer to use system Chrome
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Copy Python dependencies
COPY --from=py-builder /usr/local/lib/python3.8/site-packages/ /usr/local/lib/python3.8/site-packages/
COPY --from=py-builder /app/__pycache__/ /app/__pycache__/

# Copy TypeScript build
COPY --from=ts-builder /app/scraper/dist/ /app/scraper/dist/
COPY --from=ts-builder /app/scraper/node_modules/ /app/scraper/node_modules/

# Copy source code
COPY . .

# Create data directory
RUN mkdir -p data/chat_archive/content

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Default command
CMD ["python", "-m", "ai_components.core.main"]