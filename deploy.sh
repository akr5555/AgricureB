#!/bin/bash

# AgriCure Backend Deployment Script
# This script helps deploy the backend to various cloud platforms

set -e

echo "🚀 AgriCure Backend Deployment Script"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    print_success "Docker is installed"
}

# Check if Docker Compose is installed
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    print_success "Docker Compose is installed"
}

# Build the Docker image
build_image() {
    print_status "Building Docker image..."
    docker build -t agricure-backend:latest .
    if [ $? -eq 0 ]; then
        print_success "Docker image built successfully"
    else
        print_error "Failed to build Docker image"
        exit 1
    fi
}

# Test the Docker image locally
test_local() {
    print_status "Testing Docker image locally..."
    
    # Stop any existing container
    docker stop agricure-backend-test 2>/dev/null || true
    docker rm agricure-backend-test 2>/dev/null || true
    
    # Run the container
    docker run -d --name agricure-backend-test -p 8001:8000 agricure-backend:latest
    
    # Wait for the container to start
    sleep 10
    
    # Test health endpoint
    if curl -f http://localhost:8001/health > /dev/null 2>&1; then
        print_success "Local test passed! API is responding on http://localhost:8001"
        
        # Test prediction endpoint
        print_status "Testing prediction endpoint..."
        response=$(curl -s -X POST "http://localhost:8001/predict" \
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
            }')
        
        if echo "$response" | grep -q "fertilizer"; then
            print_success "Prediction endpoint test passed!"
        else
            print_warning "Prediction endpoint test failed, but basic health check passed"
        fi
    else
        print_error "Local test failed! API is not responding"
        docker logs agricure-backend-test
        exit 1
    fi
    
    # Cleanup
    docker stop agricure-backend-test
    docker rm agricure-backend-test
}

# Deploy with Docker Compose
deploy_compose() {
    print_status "Deploying with Docker Compose..."
    docker-compose up -d
    
    # Wait for service to be ready
    print_status "Waiting for service to be ready..."
    sleep 15
    
    if curl -f http://localhost:8000/health > /dev/null 2>&1; then
        print_success "Deployment successful! API is running on http://localhost:8000"
        print_status "You can access:"
        echo "  - API Documentation: http://localhost:8000/docs"
        echo "  - Health Check: http://localhost:8000/health"
        echo "  - Model Info: http://localhost:8000/model-info"
    else
        print_error "Deployment failed! API is not responding"
        docker-compose logs
        exit 1
    fi
}

# Deploy to Docker Hub
deploy_dockerhub() {
    read -p "Enter your Docker Hub username: " username
    read -p "Enter your Docker Hub repository name (default: agricure-backend): " repo_name
    repo_name=${repo_name:-agricure-backend}
    
    print_status "Tagging image for Docker Hub..."
    docker tag agricure-backend:latest $username/$repo_name:latest
    
    print_status "Pushing to Docker Hub..."
    docker push $username/$repo_name:latest
    
    print_success "Image pushed to Docker Hub: $username/$repo_name:latest"
    print_status "You can now pull and run this image anywhere with:"
    echo "  docker pull $username/$repo_name:latest"
    echo "  docker run -p 8000:8000 $username/$repo_name:latest"
}

# Main menu
main_menu() {
    echo ""
    echo "Select deployment option:"
    echo "1) Build and test locally"
    echo "2) Deploy with Docker Compose (recommended)"
    echo "3) Push to Docker Hub for public access"
    echo "4) All of the above"
    echo "5) Exit"
    echo ""
    read -p "Enter your choice (1-5): " choice
    
    case $choice in
        1)
            check_docker
            build_image
            test_local
            ;;
        2)
            check_docker
            check_docker_compose
            build_image
            deploy_compose
            ;;
        3)
            check_docker
            build_image
            deploy_dockerhub
            ;;
        4)
            check_docker
            check_docker_compose
            build_image
            test_local
            deploy_compose
            deploy_dockerhub
            ;;
        5)
            print_status "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid choice. Please try again."
            main_menu
            ;;
    esac
}

# Run the main menu
main_menu
