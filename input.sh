read -p "Markdown linting failed. Do you want to exit and fix it? (yes/no) " response
  echo "User response: $response"  # Debug output
  if [ "$response" = "yes" ]; then
    echo "Exiting. Please fix the issues and try again."
    exit 1
  elif [ "$response" = "no" ]; then
    echo "Continuing with commit."
    ./docker.sh
  else
    echo "Invalid response. Exiting."
    exit 1
  fi
fi