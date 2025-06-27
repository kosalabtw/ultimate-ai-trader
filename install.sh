#!/bin/bash
set -e

INSTALLER_VERSION="1.0.0"

# Get the exact creation/change time of this script file
CREATED_TIME=$(stat -c %w "$0")
if [ "$CREATED_TIME" = "-" ]; then
  # If birth time is not available, use last modification time
  CREATED_TIME=$(stat -c %y "$0")
fi

echo "Ultimate AI Trader Installer version: $INSTALLER_VERSION"
echo "Script file creation time: $CREATED_TIME"
echo "Started at: $(date)"
echo "Starting Ultimate AI Trader setup..."

# ...rest of your script...
