#!/bin/bash

# Define variables
HUGO_SITE_DIR="."
LOG_FILE="./deploy.log"
DOCKER_SCRIPT="./docker.sh"

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
  else
    echo "Invalid response. Exiting."
    exit 1
  fi
fi

# Call Docker script
log "Calling Docker script..."
bash "$DOCKER_SCRIPT" || { log "Docker script failed."; exit 1; }

log "Deployment completed successfully."
