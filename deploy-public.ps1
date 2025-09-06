# AgriCure Backend - Public Cloud Deployment Script
# This script helps deploy the backend to public cloud platforms

param(
    [string]$Action = "menu"
)

function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Check-Docker {
    try {
        $dockerVersion = docker --version
        Write-Success "Docker is installed: $dockerVersion"
        return $true
    }
    catch {
        Write-Error "Docker is not installed. Please install Docker Desktop first."
        Write-Status "Download from: https://www.docker.com/products/docker-desktop"
        return $false
    }
}

function Build-Image {
    Write-Status "Building Docker image for public deployment..."
    $result = docker build -t agricure-backend:latest .
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Docker image built successfully"
        return $true
    }
    else {
        Write-Error "Failed to build Docker image"
        return $false
    }
}

function Deploy-Railway {
    Write-Status "Deploying to Railway (Free hosting with public URL)..."
    Write-Status "Installing Railway CLI..."
    
    # Check if Node.js is installed
    try {
        $nodeVersion = node --version
        Write-Success "Node.js is installed: $nodeVersion"
    }
    catch {
        Write-Error "Node.js is required for Railway CLI. Please install Node.js first."
        Write-Status "Download from: https://nodejs.org/"
        return $false
    }
    
    # Install Railway CLI
    npm install -g @railway/cli
    
    Write-Status "Please login to Railway in the browser that will open..."
    railway login
    
    Write-Status "Creating new Railway project..."
    railway init
    
    Write-Status "Deploying to Railway..."
    railway up
    
    Write-Status "Getting your public URL..."
    $domain = railway domain
    
    Write-Success "🎉 Deployment successful!"
    Write-Success "Your API is now publicly available at: $domain"
    Write-Status "API endpoints:"
    Write-Host "  - Health Check: $domain/health" -ForegroundColor Cyan
    Write-Host "  - API Docs: $domain/docs" -ForegroundColor Cyan
    Write-Host "  - Predict: $domain/predict" -ForegroundColor Cyan
    
    return $true
}

function Deploy-Render {
    Write-Status "Setting up deployment to Render (Free hosting)..."
    Write-Warning "For Render deployment, you need to:"
    Write-Host "1. Push your code to GitHub" -ForegroundColor Yellow
    Write-Host "2. Go to https://render.com" -ForegroundColor Yellow
    Write-Host "3. Sign up/Login with GitHub" -ForegroundColor Yellow
    Write-Host "4. Click 'New +' > 'Web Service'" -ForegroundColor Yellow
    Write-Host "5. Connect your GitHub repository" -ForegroundColor Yellow
    Write-Host "6. Use these settings:" -ForegroundColor Yellow
    Write-Host "   - Build Command: docker build -t agricure-backend ." -ForegroundColor Cyan
    Write-Host "   - Start Command: uvicorn main:app --host 0.0.0.0 --port \$PORT" -ForegroundColor Cyan
    Write-Host "   - Environment: Docker" -ForegroundColor Cyan
    Write-Host "7. Click 'Create Web Service'" -ForegroundColor Yellow
    
    $openRender = Read-Host "Would you like to open Render in your browser? (y/n)"
    if ($openRender.ToLower() -eq "y") {
        Start-Process "https://render.com"
    }
    
    return $true
}

function Deploy-Heroku {
    Write-Status "Deploying to Heroku (Free tier discontinued, but offers affordable hosting)..."
    
    # Check if Heroku CLI is installed
    try {
        $herokuVersion = heroku --version
        Write-Success "Heroku CLI is installed: $herokuVersion"
    }
    catch {
        Write-Error "Heroku CLI is not installed."
        Write-Status "Download from: https://devcenter.heroku.com/articles/heroku-cli"
        
        $installHeroku = Read-Host "Would you like to download Heroku CLI? (y/n)"
        if ($installHeroku.ToLower() -eq "y") {
            Start-Process "https://devcenter.heroku.com/articles/heroku-cli"
        }
        return $false
    }
    
    Write-Status "Logging into Heroku..."
    heroku login
    
    $appName = Read-Host "Enter your Heroku app name (must be unique)"
    
    Write-Status "Creating Heroku app..."
    heroku create $appName
    
    Write-Status "Logging into Heroku Container Registry..."
    heroku container:login
    
    Write-Status "Building and pushing to Heroku..."
    heroku container:push web -a $appName
    heroku container:release web -a $appName
    
    $appUrl = "https://$appName.herokuapp.com"
    
    Write-Success "🎉 Deployment successful!"
    Write-Success "Your API is now publicly available at: $appUrl"
    Write-Status "API endpoints:"
    Write-Host "  - Health Check: $appUrl/health" -ForegroundColor Cyan
    Write-Host "  - API Docs: $appUrl/docs" -ForegroundColor Cyan
    Write-Host "  - Predict: $appUrl/predict" -ForegroundColor Cyan
    
    return $true
}

function Deploy-DockerHub {
    $username = Read-Host "Enter your Docker Hub username"
    $repoName = Read-Host "Enter your Docker Hub repository name (default: agricure-backend)"
    if ([string]::IsNullOrEmpty($repoName)) {
        $repoName = "agricure-backend"
    }
    
    Write-Status "Logging into Docker Hub..."
    docker login
    
    Write-Status "Tagging image for Docker Hub..."
    docker tag agricure-backend:latest "$username/$repoName`:latest"
    
    Write-Status "Pushing to Docker Hub..."
    docker push "$username/$repoName`:latest"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Image pushed to Docker Hub: $username/$repoName`:latest"
        Write-Status "Your image is now public! Anyone can deploy it with:"
        Write-Host "  docker run -p 8000:8000 $username/$repoName`:latest" -ForegroundColor Cyan
        Write-Warning "Note: This just makes the image public. You still need a cloud platform to host it publicly."
        return $true
    }
    else {
        Write-Error "Failed to push to Docker Hub"
        return $false
    }
}

function Show-PublicDeploymentOptions {
    Write-Host ""
    Write-Host "🌐 AgriCure Backend - PUBLIC Cloud Deployment" -ForegroundColor Magenta
    Write-Host "=============================================" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "Choose a PUBLIC hosting platform:" -ForegroundColor White
    Write-Host ""
    Write-Host "1) 🚂 Railway (RECOMMENDED - Free, Easy, Public URL)" -ForegroundColor Green
    Write-Host "   - Free tier with 500 hours/month" -ForegroundColor Gray
    Write-Host "   - Automatic public URL" -ForegroundColor Gray
    Write-Host "   - Easy GitHub integration" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2) 🎨 Render (Free, GitHub integration required)" -ForegroundColor Yellow
    Write-Host "   - Free tier available" -ForegroundColor Gray
    Write-Host "   - Requires GitHub repository" -ForegroundColor Gray
    Write-Host "   - Automatic deployments" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3) 🟣 Heroku (Paid, but reliable)" -ForegroundColor Magenta
    Write-Host "   - \$7/month for basic dyno" -ForegroundColor Gray
    Write-Host "   - Very reliable and popular" -ForegroundColor Gray
    Write-Host "   - Container support" -ForegroundColor Gray
    Write-Host ""
    Write-Host "4) 🐳 Docker Hub (Publish image only)" -ForegroundColor Blue
    Write-Host "   - Makes your image publicly available" -ForegroundColor Gray
    Write-Host "   - You still need hosting platform" -ForegroundColor Gray
    Write-Host ""
    Write-Host "5) ❌ Exit" -ForegroundColor Red
    Write-Host ""
    
    $choice = Read-Host "Enter your choice (1-5)"
    
    switch ($choice) {
        "1" {
            if ((Check-Docker) -and (Build-Image)) {
                Deploy-Railway
            }
        }
        "2" {
            if ((Check-Docker) -and (Build-Image)) {
                Deploy-Render
            }
        }
        "3" {
            if ((Check-Docker) -and (Build-Image)) {
                Deploy-Heroku
            }
        }
        "4" {
            if ((Check-Docker) -and (Build-Image)) {
                Deploy-DockerHub
            }
        }
        "5" {
            Write-Status "Goodbye!"
            exit 0
        }
        default {
            Write-Error "Invalid choice. Please try again."
            Show-PublicDeploymentOptions
        }
    }
}

function Show-QuickStart {
    Write-Host ""
    Write-Host "🚀 QUICK START RECOMMENDATION" -ForegroundColor Green
    Write-Host "=============================" -ForegroundColor Green
    Write-Host ""
    Write-Host "For the fastest public deployment, I recommend Railway:" -ForegroundColor White
    Write-Host ""
    Write-Host "1. Make sure you have Node.js installed" -ForegroundColor Yellow
    Write-Host "2. Run this script and choose option 1 (Railway)" -ForegroundColor Yellow
    Write-Host "3. You'll get a public URL like: https://your-app.railway.app" -ForegroundColor Yellow
    Write-Host "4. Use that URL in your frontend to connect to the API" -ForegroundColor Yellow
    Write-Host ""
    
    $continue = Read-Host "Ready to proceed with public deployment? (y/n)"
    if ($continue.ToLower() -eq "y") {
        Show-PublicDeploymentOptions
    }
    else {
        Write-Status "Goodbye!"
    }
}

# Main execution
if ($Action -eq "menu") {
    Show-QuickStart
}
else {
    switch ($Action.ToLower()) {
        "railway" {
            if ((Check-Docker) -and (Build-Image)) { Deploy-Railway }
        }
        "render" {
            if ((Check-Docker) -and (Build-Image)) { Deploy-Render }
        }
        "heroku" {
            if ((Check-Docker) -and (Build-Image)) { Deploy-Heroku }
        }
        "dockerhub" {
            if ((Check-Docker) -and (Build-Image)) { Deploy-DockerHub }
        }
        default {
            Write-Error "Invalid action. Use: railway, render, heroku, dockerhub, or menu"
            Show-PublicDeploymentOptions
        }
    }
}
