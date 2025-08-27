#!/bin/sh

# Ensure the script is executable
chmod +x "$0"

# Set the project directory to three directories back from where the script resides
PROJECT_DIR=$(dirname $(dirname $(dirname $(dirname $(realpath $0)))))

# Debugging: Print the resolved project directory
echo "Resolved PROJECT_DIR: $PROJECT_DIR"

# Check if .env already exists
if [ ! -f "$PROJECT_DIR/.env" ]; then
  echo "Copying .env.example to .env..."
  cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
  echo ".env file created."
else
  echo ".env file already exists. Skipping copy."
fi
