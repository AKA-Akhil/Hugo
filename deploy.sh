#!/bin/bash

# Define variables
HUGO_SITE_DIR="."
DOCKER_NAME="my-hugo-site"
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
hugo --gc --minify >> "$LOG_FILE" 2>&1 || { log "Hugo site failed to build."; exit 1; }

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

        # Build Docker image and run container
        echo "Building Docker image..."
        docker build -t "$DOCKER_NAME" . || { log "Failed to build Docker image."; exit 1; }

        echo "Running Docker container..."
        docker run -d -p "$PORT":1313 --name "$DOCKER_NAME" "$DOCKER_NAME" || { log "Failed to run Docker container."; exit 1; }

        # Test Docker container
        echo "Testing Docker container..."
        sleep 10 # Wait for the container to be ready
        if ! curl -s http://localhost:$PORT > /dev/null; then
            log "Docker container did not serve the website properly."
            docker stop "$DOCKER_NAME"
            docker rm "$DOCKER_NAME"
            exit 1
        fi
        echo "Docker container test passed."

        # Cleanup
        echo "Cleaning up..."
        docker stop "$DOCKER_NAME"
        docker rm "$DOCKER_NAME"

        log "Deployment completed successfully."
    else
        echo "Invalid response. Exiting."
        exit 1
    fi
else
    echo "Markdown linting passed. Proceeding with commit."

    # Build Docker image and run container
    echo "Building Docker image..."
    docker build -t "$DOCKER_NAME" . || { log "Failed to build Docker image."; exit 1; }

    echo "Running Docker container..."
    docker run -d -p "$PORT":1313 --name "$DOCKER_NAME" "$DOCKER_NAME" || { log "Failed to run Docker container."; exit 1; }

    # Test Docker container
    echo "Testing Docker container..."
    sleep 10 # Wait for the container to be ready
    if ! curl -s http://localhost:$PORT > /dev/null; then
        log "Docker container did not serve the website properly."
        docker stop "$DOCKER_NAME"
        docker rm "$DOCKER_NAME"
        exit 1
    fi
    echo "Docker container test passed."


    log "Deployment completed successfully."
fi
