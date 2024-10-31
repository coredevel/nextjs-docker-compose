#!/bin/bash

# Ensure the TARGET_WORKDIR environment variable is set
export TARGET_WORKDIR=${TARGET_WORKDIR:-/project}

# Path to the bootstrap script
BOOTSTRAP_SCRIPT=${TARGET_WORKDIR}/.docker/scripts/bootstrap.sh

# Check if the bootstrap script exists
if [ -f "$BOOTSTRAP_SCRIPT" ]; then
  # Make sure it's executable
  chmod +x "$BOOTSTRAP_SCRIPT"
  # Run the bootstrap script
  "$BOOTSTRAP_SCRIPT"
else
  echo "Bootstrap script not found at $BOOTSTRAP_SCRIPT"
  exit 1
fi

# Navigate to the project directory
cd "${TARGET_WORKDIR}/next"

# Execute the CMD passed from the Dockerfile or docker-compose
exec "$@"
