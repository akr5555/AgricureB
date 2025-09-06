# 🚀 AgriCure Backend - Docker Deployment Guide

This guide provides comprehensive instructions for deploying the AgriCure Backend API using Docker for public access.

## 📋 Prerequisites

- **Docker Desktop**: [Download and install](https://www.docker.com/products/docker-desktop)
- **Docker Hub Account**: [Create account](https://hub.docker.com/) (for public deployment)
- **Git**: For cloning the repository
- **Postman** (optional): For API testing

## 🏗️ Project Structure

```
backend/
├── Dockerfile              # Production-ready Docker configuration
├── docker-compose.yml      # Docker Compose for local deployment
├── deploy.sh               # Linux/Mac deployment script
├── deploy.ps1              # Windows PowerShell deployment script
├── requirements.txt        # Python dependencies
├── main.py                 # FastAPI application
├── soil_api.py            # Soil data API integration
├── models/                # ML models (pickle files)
│   ├── classifier.pkl
│   └── fertilizer.pkl
└── static/                # Static assets
```

## 🚀 Quick Start

### Option 1: Automated Deployment (Recommended)

#### For Windows Users:
```powershell
# Run PowerShell as Administrator
cd backend
.\deploy.ps1
```

#### For Linux/Mac Users:
```bash
cd backend
chmod +x deploy.sh
./deploy.sh
```

### Option 2: Manual Deployment

#### Step 1: Build Docker Image
```bash
docker build -t agricure-backend:latest .
```

#### Step 2: Test Locally
```bash
# Run container
docker run -d --name agricure-test -p 8000:8000 agricure-backend:latest

# Test health endpoint
curl http://localhost:8000/health

# Test prediction endpoint
curl -X POST "http://localhost:8000/predict" \
  -H "Content-Type: application/json" \
  -d '{
    "Temperature": 26.0,
    "Humidity": 80.0,
    "Moisture": 35.0,
    "Soil_Type": "Loamy",
    "Crop_Type": "rice",
    "Nitrogen": 85.0,
    "Potassium": 45.0,
    "Phosphorous": 35.0
  }'

# Cleanup
docker stop agricure-test && docker rm agricure-test
```

#### Step 3: Deploy with Docker Compose
```bash
docker-compose up -d
```

## 🌐 Public Deployment Options

### 1. Docker Hub Deployment

#### Tag and Push to Docker Hub:
```bash
# Tag your image
docker tag agricure-backend:latest YOUR_USERNAME/agricure-backend:latest

# Login to Docker Hub
docker login

# Push to Docker Hub
docker push YOUR_USERNAME/agricure-backend:latest
```

#### Deploy Anywhere:
```bash
# Pull and run from Docker Hub
docker pull YOUR_USERNAME/agricure-backend:latest
docker run -d -p 8000:8000 YOUR_USERNAME/agricure-backend:latest
```

### 2. Cloud Platform Deployment

#### Railway (Free Tier Available)
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login and deploy
railway login
railway init
railway up
```

#### Heroku Container Registry
```bash
# Install Heroku CLI and login
heroku login
heroku container:login

# Create app and deploy
heroku create your-app-name
heroku container:push web -a your-app-name
heroku container:release web -a your-app-name
```

#### Google Cloud Run
```bash
# Build and push to Google Container Registry
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/agricure-backend

# Deploy to Cloud Run
gcloud run deploy --image gcr.io/YOUR_PROJECT_ID/agricure-backend --platform managed
```

#### AWS Elastic Container Service (ECS)
```bash
# Push to Amazon ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

docker tag agricure-backend:latest YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/agricure-backend:latest
docker push YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/agricure-backend:latest
```

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Port to run the server | `8000` |
| `PYTHONUNBUFFERED` | Python output buffering | `1` |

### Health Checks

The application includes built-in health checks:
- **Endpoint**: `/health`
- **Docker Health Check**: Automatic container health monitoring
- **Interval**: 30 seconds
- **Timeout**: 30 seconds
- **Retries**: 3

## 📊 API Endpoints

Once deployed, your API will be available at:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | API information and status |
| `/health` | GET | Health check endpoint |
| `/docs` | GET | Interactive API documentation |
| `/model-info` | GET | ML model information |
| `/predict` | POST | Fertilizer recommendation |
| `/predict-by-location` | POST | Location-based prediction |

## 🧪 Testing Your Deployment

### 1. Basic Health Check
```bash
curl https://your-domain.com/health
```

### 2. Test Prediction Endpoint
```bash
curl -X POST "https://your-domain.com/predict" \
  -H "Content-Type: application/json" \
  -d '{
    "Temperature": 26.0,
    "Humidity": 80.0,
    "Moisture": 35.0,
    "Soil_Type": "Loamy",
    "Crop_Type": "rice",
    "Nitrogen": 85.0,
    "Potassium": 45.0,
    "Phosphorous": 35.0
  }'
```

### 3. Interactive Testing
Visit `https://your-domain.com/docs` for interactive API documentation.

## 🔒 Security Features

- **Non-root user**: Container runs as non-privileged user
- **Read-only volumes**: Static files mounted as read-only
- **Health checks**: Automatic container health monitoring
- **CORS configuration**: Properly configured cross-origin requests
- **Input validation**: Pydantic models for request validation

## 📈 Performance Optimization

- **Multi-stage build**: Optimized Docker image size
- **Dependency caching**: Efficient layer caching
- **Uvicorn ASGI server**: High-performance async server
- **Model caching**: ML models loaded once at startup

## 🛠️ Troubleshooting

### Common Issues:

1. **Port already in use**:
   ```bash
   docker ps  # Check running containers
   docker stop container_name
   ```

2. **Model files not found**:
   - Ensure `models/classifier.pkl` and `models/fertilizer.pkl` exist
   - Check file permissions

3. **Memory issues**:
   - Increase Docker memory allocation
   - Monitor container resources: `docker stats`

4. **Network connectivity**:
   ```bash
   docker network ls
   docker network inspect bridge
   ```

### Logs:
```bash
# View container logs
docker logs agricure-backend

# Follow logs in real-time
docker logs -f agricure-backend

# Docker Compose logs
docker-compose logs -f
```

## 📞 Support

If you encounter issues:

1. Check the logs using commands above
2. Verify all model files are present
3. Ensure Docker has sufficient resources allocated
4. Test locally before deploying to cloud platforms

## 🎯 Next Steps

After successful deployment:

1. Set up monitoring and logging
2. Configure domain name and SSL certificate
3. Set up CI/CD pipeline for automated deployments
4. Implement rate limiting and authentication
5. Add backup and disaster recovery procedures

---

**Happy Deploying! 🚀**
