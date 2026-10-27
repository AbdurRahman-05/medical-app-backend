# Backend Deployment Guide (Live Production)

This guide explains how to deploy the ClinResearch backend API connected to the clean **NeonDB Cloud PostgreSQL** database.

---

## 1. Cloud Database Status: CLEAN & READY

The database on NeonDB is 100% clean and operational:
- **Host**: `ep-sparkling-river-b4kpg4sj-pooler.c-6.us-east-2.aws.neon.tech`
- **Database**: `neondb`
- **SSL**: `require`
- **Current Data**:
  - `projects`: `0` (Zero mock/test text)
  - `chat_messages`: `0`
  - `protocol_versions`: `0`
  - `iec_items`: `0`
  - `audit_events`: Clean baseline initialization (`AUD-0001`)

Whenever you need to wipe test records in the future, run:
```bash
npm run clean-db
```

---

## 2. Option A: Deploy to Render (Recommended — Free & Easiest)

1. Push your repository to **GitHub** or **GitLab**.
2. Go to [render.com](https://render.com) and click **New + > Web Service**.
3. Select your repository.
4. Render will automatically detect [`render.yaml`](file:///d:/flutter%20medical%20app/render.yaml):
   - **Environment**: Node
   - **Build Command**: `npm install`
   - **Start Command**: `node server.js`
   - **Health Check Path**: `/health`
5. Under **Environment Variables**, verify:
   - `DATABASE_URL`: `postgresql://neondb_owner:<YOUR_PASSWORD>@ep-sparkling-river-b4kpg4sj-pooler.c-6.us-east-2.aws.neon.tech/neondb?sslmode=require`
   - `PORT`: `5000`
6. Click **Create Web Service**.
7. In ~60 seconds, your backend is live with a public HTTPS URL (e.g. `https://clinresearch-backend.onrender.com`).

---

## 3. Option B: Deploy to Railway

1. Go to [railway.app](https://railway.app).
2. Click **New Project > Deploy from GitHub repo**.
3. Select this repository. Railway will detect [`railway.json`](file:///d:/flutter%20medical%20app/railway.json).
4. Add the `DATABASE_URL` environment variable under **Variables**.
5. Click **Deploy**.

---

## 4. Option C: Deploy via Docker (Any VPS, Fly.io, or AWS ECS)

Build and run the container locally or on any cloud server:
```bash
# Build Docker image
docker build -t clinresearch-backend .

# Run container
docker run -p 5000:5000 \
  -e DATABASE_URL="postgresql://neondb_owner:<YOUR_PASSWORD>@ep-sparkling-river-b4kpg4sj-pooler.c-6.us-east-2.aws.neon.tech/neondb?sslmode=require" \
  clinresearch-backend
```

---

## 5. Live Endpoints Included

Once deployed, your backend provides:
- **`GET /health`** — Real-time healthcheck & NeonDB connection verification
- **`GET /api/live-sync`** — Live pipeline distribution & protocol dossier feed
- **`GET /api/projects`** — Live active studies
- **`POST /api/projects`** — Post new clinical observations
- **`GET /api/audit-events`** — Regulatory audit log
- **`POST /api/clean-database`** — Instant reset to clean live state
- **`GET /admin`** — Deployed Super Admin Governance Web Portal
