#!/bin/bash

# Define variables
HUGO_SITE_DIR="."
DOCKER_IMAGE_NAME="my-hugo-site"
DOCKER_CONTAINER_NAME="my-hugo-site-container"
LOG_FILE="./deploy.log"
PORT=1313

# Function to log messages
log() {
  echo "$(date): $1" >> "$LOG_FILE"
}

# Navigate to Hugo site directory
cd "$HUGO_SITE_DIR" || { log "Failed to change directory to Hugo site."; exit 1; }

# Code testing - Linting and Validation
log "Starting code testing..."
echo "Running Hugo tests..."
hugo --gc --minify > "$LOG_FILE" 2>&1 || { log "Hugo site failed to build."; exit 1; }

# Run markdownlint (ensure it is installed on your local machine)
echo "Running markdownlint..."
markdownlint '**/*.md' >> "$LOG_FILE" 2>&1

if [ $? -ne 0 ]; then
  echo "Markdown linting failed. Asking user to exit or continue..."
  read -p "Markdown linting failed. Do you want to exit and fix it? (yes/no) " response
  echo "User response: $response"  # Debug output
  if [ "$response" = "yes" ]; then
    echo "Exiting. Please fix the issues and try again."
    exit 1
  elif [ "$response" = "no" ]; then
    echo "Continuing with commit."
    # Build Docker image
log "Building Docker image..."
docker build -t "$DOCKER_IMAGE_NAME" . >> "$LOG_FILE" 2>&1 || { log "Failed to build Docker image."; exit 1; }

# Stop and remove existing container if running
if docker ps -q --filter "name=$DOCKER_CONTAINER_NAME" > /dev/null; then
  log "Stopping existing Docker container..."
  docker stop "$DOCKER_CONTAINER_NAME" >> "$LOG_FILE" 2>&1
  docker rm "$DOCKER_CONTAINER_NAME" >> "$LOG_FILE" 2>&1
fi

# Run Docker container
log "Running Docker container..."
docker run -d --name "$DOCKER_CONTAINER_NAME" -p "$PORT":13 "$DOCKER_IMAGE_NAME" >> "$LOG_FILE" 2>&1 || { log "Failed to run Docker container."; exit 1; }

# Test Docker container
log "Testing Docker container..."
sleep 10 # Wait for the container to be ready
if ! curl -s http://localhost:$PORT > /dev/null; then
  log "Docker container did not serve the website properly."
  docker stop "$DOCKER_CONTAINER_NAME" >> "$LOG_FILE" 2>&1
  exit 1
fi
log "Docker container test passed."

# Cleanup
log "Cleaning up..."
docker stop "$DOCKER_CONTAINER_NAME" >> "$LOG_FILE" 2>&1
docker rm "$DOCKER_CONTAINER_NAME" >> "$LOG_FILE" 2>&1

log "Deployment completed successfully."
  else
    echo "Invalid response. Exiting."
    exit 1
  fi
fi


