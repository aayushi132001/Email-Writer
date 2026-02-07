# 🚀 Email Writer Deployment Roadmap

## Overview

This guide covers deploying:
- **Backend (Spring Boot)** → **Render** (using Docker)
- **Frontend (React/Vite)** → **Vercel**

---

## 📋 Prerequisites

Before starting deployment:

1. **GitHub Repository**: Ensure your code is pushed to GitHub
2. **Accounts**: Create accounts on:
   - [Render](https://render.com) (for backend)
   - [Vercel](https://vercel.com) (for frontend)
3. **API Keys**: Have your `GEMINI_URL` and `GEMINI_KEY` ready

---

## 🔧 Backend Deployment (Render)

### Step 1: Prepare Your Repository

Ensure these files exist in your `email-writer/` directory:
- ✅ `Dockerfile` (already created)
- ✅ `.dockerignore` (already created)

### Step 2: Update Java Version (Important!)

The current `pom.xml` uses Java 25, which isn't widely supported. Update to Java 21 LTS:

```xml
<!-- In pom.xml, change this: -->
<properties>
    <java.version>21</java.version>  <!-- Changed from 25 -->
</properties>
```

### Step 3: Create Render Web Service

1. **Log in to Render** → [https://dashboard.render.com](https://dashboard.render.com)

2. **Click "New +"** → Select **"Web Service"**

3. **Connect Repository**:
   - Select your GitHub repository
   - Grant access if prompted

4. **Configure Service**:
   | Setting | Value |
   |---------|-------|
   | **Name** | `email-writer-api` |
   | **Region** | Choose closest to your users |
   | **Branch** | `main` (or your default branch) |
   | **Root Directory** | `email-writer` |
   | **Runtime** | `Docker` |

5. **Instance Type**: 
   - Start with **Free** tier for testing
   - Upgrade to **Starter ($7/month)** for production

### Step 4: Configure Environment Variables

In Render dashboard, add these environment variables:

| Variable | Value | Description |
|----------|-------|-------------|
| `GEMINI_URL` | `https://generativelanguage.googleapis.com/...` | Your Gemini API URL |
| `GEMINI_KEY` | `your-api-key` | Your Gemini API Key |
| `JAVA_OPTS` | `-Xms256m -Xmx512m` | JVM memory settings |

### Step 5: Deploy

1. Click **"Create Web Service"**
2. Render will:
   - Clone your repository
   - Build the Docker image
   - Deploy the container
3. Wait for deployment (first build takes ~5-10 minutes)

### Step 6: Get Your Backend URL

After deployment, Render provides a URL like:
```
https://email-writer-api.onrender.com
```

**Save this URL** - you'll need it for the frontend!

### ⚠️ Important Notes for Render

- **Cold Starts**: Free tier services sleep after 15 minutes of inactivity. First request may take 30-60 seconds.
- **Auto-Deploy**: Enable auto-deploy for automatic deployments on git push.

---

## 🎨 Frontend Deployment (Vercel)

### Step 1: Configure API Endpoint

Before deploying, update your frontend to use the backend URL.

Create or update `.env.production` in `email-writer-react/`:

```env
VITE_API_URL=https://email-writer-api.onrender.com
```

Update your API calls to use the environment variable:

```javascript
// Example: In your API service file
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080';

// Use API_URL for all fetch/axios calls
```

### Step 2: Deploy to Vercel

#### Option A: Vercel CLI (Recommended for first-time)

```bash
# Install Vercel CLI
npm install -g vercel

# Navigate to frontend directory
cd email-writer-react

# Deploy
vercel

# Follow the prompts:
# - Set up and deploy? Yes
# - Which scope? Select your account
# - Link to existing project? No
# - Project name? email-writer-react
# - Directory? ./
# - Override settings? No
```

#### Option B: Vercel Dashboard

1. **Log in to Vercel** → [https://vercel.com](https://vercel.com)

2. **Click "Add New..."** → **"Project"**

3. **Import Repository**:
   - Connect your GitHub account
   - Select your repository

4. **Configure Project**:
   | Setting | Value |
   |---------|-------|
   | **Project Name** | `email-writer` |
   | **Framework Preset** | `Vite` |
   | **Root Directory** | `email-writer-react` |
   | **Build Command** | `npm run build` (default) |
   | **Output Directory** | `dist` (default) |

5. **Environment Variables**:
   Add under "Environment Variables":
   | Name | Value |
   |------|-------|
   | `VITE_API_URL` | `https://email-writer-api.onrender.com` |

6. **Click "Deploy"**

### Step 3: Get Your Frontend URL

After deployment, Vercel provides URLs like:
```
https://email-writer.vercel.app
https://email-writer-<username>.vercel.app
```

---

## 🔒 CORS Configuration

Ensure your backend allows requests from your Vercel domain.

Add CORS configuration in your Spring Boot app:

```java
// Create a new file: src/main/java/com/example/emailwriter/config/CorsConfig.java

package com.example.emailwriter.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.Arrays;
import java.util.List;

@Configuration
public class CorsConfig {

    @Bean
    public CorsFilter corsFilter() {
        CorsConfiguration config = new CorsConfiguration();
        
        // Allow your Vercel domain
        config.setAllowedOrigins(Arrays.asList(
            "http://localhost:5173",           // Local development
            "https://email-writer.vercel.app", // Production (update with your actual URL)
            "https://*.vercel.app"             // All Vercel preview deployments
        ));
        
        config.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of("*"));
        config.setAllowCredentials(true);
        config.setMaxAge(3600L);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        
        return new CorsFilter(source);
    }
}
```

---

## ✅ Deployment Checklist

### Backend (Render)
- [ ] Updated Java version to 21 in `pom.xml`
- [ ] Dockerfile is in `email-writer/` directory
- [ ] Created Render Web Service with Docker runtime
- [ ] Set `GEMINI_URL` environment variable
- [ ] Set `GEMINI_KEY` environment variable
- [ ] Deployment successful (green status)
- [ ] Tested API endpoint is accessible

### Frontend (Vercel)
- [ ] Set `VITE_API_URL` to Render backend URL
- [ ] Deployed to Vercel
- [ ] Verified CORS is configured
- [ ] Tested frontend can communicate with backend

---

## 🐛 Troubleshooting

### Backend Issues

| Problem | Solution |
|---------|----------|
| Build fails with Java version error | Ensure `pom.xml` has `<java.version>21</java.version>` |
| Container crashes on startup | Check Render logs for missing env variables |
| Out of memory | Increase instance size or adjust `JAVA_OPTS` |
| Slow first response | Expected on free tier (cold start) |

### Frontend Issues

| Problem | Solution |
|---------|----------|
| CORS errors | Add your Vercel domain to backend CORS config |
| API calls fail | Verify `VITE_API_URL` is set correctly |
| Build fails | Check Node version compatibility |
| 404 on routes | Add `vercel.json` with rewrites for SPA |

### Create `vercel.json` for SPA routing:

```json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/" }
  ]
}
```

---

## 📊 Monitoring & Logs

### Render
- View logs: Dashboard → Service → Logs tab
- Metrics: Monitor CPU, Memory, and requests
- Alerts: Set up email notifications for failures

### Vercel
- View logs: Dashboard → Project → Functions tab
- Analytics: Real User Monitoring (Pro plan)
- Preview deployments: Automatic for each PR

---

## 💰 Pricing Summary

| Service | Tier | Cost | Limitations |
|---------|------|------|-------------|
| **Render Free** | Free | $0/month | 750 hours, sleeps after 15min |
| **Render Starter** | Paid | $7/month | Always on, 0.5 CPU, 512MB RAM |
| **Vercel Hobby** | Free | $0/month | Personal use, 100GB bandwidth |
| **Vercel Pro** | Paid | $20/month | Team features, analytics |

---

## 🔄 CI/CD Pipeline (Optional)

Both Render and Vercel support automatic deployments on git push:

1. **Enable Auto-Deploy** on both platforms
2. **Push to main branch** → Both frontend and backend redeploy automatically
3. **Preview Deployments**: Vercel creates preview URLs for PRs

---

## 📞 Support Resources

- **Render Docs**: [https://render.com/docs](https://render.com/docs)
- **Vercel Docs**: [https://vercel.com/docs](https://vercel.com/docs)
- **Spring Boot Deployment**: [https://spring.io/guides/gs/spring-boot-docker](https://spring.io/guides/gs/spring-boot-docker)
