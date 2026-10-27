# Production Dockerfile for ClinResearch Backend API & Super Admin Portal
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy package descriptors
COPY package*.json ./

# Install production dependencies
RUN npm ci --only=production

# Copy application files
COPY server.js ./
COPY scripts/ ./scripts/
COPY super_admin_web/ ./super_admin_web/

# Expose port (Render/Railway injects PORT automatically)
ENV PORT=5000
EXPOSE 5000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5000/health || exit 1

# Start server
CMD ["node", "server.js"]
