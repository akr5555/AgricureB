# AgriCure Backend Deployment Script for Windows PowerShell
# This script helps deploy the backend to various cloud platforms

param(
    [string]$Action = "menu"
)

# Colors for output
$Host.UI.RawUI.ForegroundColor = "White"

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

function Check-DockerCompose {
    try {
        $composeVersion = docker-compose --version
        Write-Success "Docker Compose is installed: $composeVersion"
        return $true
    }
    catch {
        try {
            $composeVersion = docker compose version
            Write-Success "Docker Compose is installed: $composeVersion"
            return $true
        }
        catch {
            Write-Error "Docker Compose is not installed."
            return $false
        }
    }
}

function Build-Image {
    Write-Status "Building Docker image..."
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

function Test-Local {
    Write-Status "Testing Docker image locally..."
    
    # Stop any existing container
    docker stop agricure-backend-test 2>$null
    docker rm agricure-backend-test 2>$null
    
    # Run the container
    docker run -d --name agricure-backend-test -p 8001:8000 agricure-backend:latest
    
    # Wait for the container to start
    Write-Status "Waiting for container to start..."
    Start-Sleep -Seconds 15
    
    # Test health endpoint
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8001/health" -Method Get -TimeoutSec 10
        Write-Success "Local test passed! API is responding on http://localhost:8001"
        
        # Test prediction endpoint
        Write-Status "Testing prediction endpoint..."
        $body = @{
            Temperature = 26.0
            Humidity = 80.0
            Moisture = 35.0
            Soil_Type = "Loamy"
            Crop_Type = "rice"
            Nitrogen = 85.0
            Potassium = 45.0
            Phosphorous = 35.0
        } | ConvertTo-Json
        
        $predResponse = Invoke-RestMethod -Uri "http://localhost:8001/predict" -Method Post -Body $body -ContentType "application/json" -TimeoutSec 10
        
        if ($predResponse.fertilizer) {
            Write-Success "Prediction endpoint test passed!"
        }
        else {
            Write-Warning "Prediction endpoint test failed, but basic health check passed"
        }
    }
    catch {
        Write-Error "Local test failed! API is not responding"
        docker logs agricure-backend-test
        return $false
    }
    finally {
        # Cleanup
        docker stop agricure-backend-test 2>$null
        docker rm agricure-backend-test 2>$null
    }
    
    return $true
}

function Deploy-Compose {
    Write-Status "Deploying with Docker Compose..."
    docker-compose up -d
    
    # Wait for service to be ready
    Write-Status "Waiting for service to be ready..."
    Start-Sleep -Seconds 20
    
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8000/health" -Method Get -TimeoutSec 10
        Write-Success "Deployment successful! API is running on http://localhost:8000"
        Write-Status "You can access:"
        Write-Host "  - API Documentation: http://localhost:8000/docs" -ForegroundColor Cyan
        Write-Host "  - Health Check: http://localhost:8000/health" -ForegroundColor Cyan
        Write-Host "  - Model Info: http://localhost:8000/model-info" -ForegroundColor Cyan
        return $true
    }
    catch {
        Write-Error "Deployment failed! API is not responding"
        docker-compose logs
        return $false
    }
}

function Deploy-DockerHub {
    $username = Read-Host "Enter your Docker Hub username"
    $repoName = Read-Host "Enter your Docker Hub repository name (default: agricure-backend)"
    if ([string]::IsNullOrEmpty($repoName)) {
        $repoName = "agricure-backend"
    }
    
    Write-Status "Tagging image for Docker Hub..."
    docker tag agricure-backend:latest "$username/$repoName`:latest"
    
    Write-Status "Pushing to Docker Hub..."
    docker push "$username/$repoName`:latest"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Image pushed to Docker Hub: $username/$repoName`:latest"
        Write-Status "You can now pull and run this image anywhere with:"
        Write-Host "  docker pull $username/$repoName`:latest" -ForegroundColor Cyan
        Write-Host "  docker run -p 8000:8000 $username/$repoName`:latest" -ForegroundColor Cyan
        return $true
    }
    else {
        Write-Error "Failed to push to Docker Hub"
        return $false
    }
}

function Show-Menu {
    Write-Host ""
    Write-Host "🚀 AgriCure Backend Deployment Script" -ForegroundColor Magenta
    Write-Host "======================================" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "Select deployment option:" -ForegroundColor White
    Write-Host "1) Build and test locally" -ForegroundColor Yellow
    Write-Host "2) Deploy with Docker Compose (recommended)" -ForegroundColor Yellow
    Write-Host "3) Push to Docker Hub for public access" -ForegroundColor Yellow
    Write-Host "4) All of the above" -ForegroundColor Yellow
    Write-Host "5) Exit" -ForegroundColor Yellow
    Write-Host ""
    
    $choice = Read-Host "Enter your choice (1-5)"
    
    switch ($choice) {
        "1" {
            if ((Check-Docker) -and (Build-Image)) {
                Test-Local
            }
        }
        "2" {
            if ((Check-Docker) -and (Check-DockerCompose) -and (Build-Image)) {
                Deploy-Compose
            }
        }
        "3" {
            if ((Check-Docker) -and (Build-Image)) {
                Deploy-DockerHub
            }
        }
        "4" {
            if ((Check-Docker) -and (Check-DockerCompose) -and (Build-Image)) {
                if ((Test-Local) -and (Deploy-Compose)) {
                    Deploy-DockerHub
                }
            }
        }
        "5" {
            Write-Status "Goodbye!"
            exit 0
        }
        default {
            Write-Error "Invalid choice. Please try again."
            Show-Menu
        }
    }
}

# Main execution
if ($Action -eq "menu") {
    Show-Menu
}
else {
    switch ($Action.ToLower()) {
        "build" {
            if (Check-Docker) { Build-Image }
        }
        "test" {
            if ((Check-Docker) -and (Build-Image)) { Test-Local }
        }
        "deploy" {
            if ((Check-Docker) -and (Check-DockerCompose) -and (Build-Image)) { Deploy-Compose }
        }
        "push" {
            if ((Check-Docker) -and (Build-Image)) { Deploy-DockerHub }
        }
        default {
            Write-Error "Invalid action. Use: build, test, deploy, push, or menu"
        }
    }
}
