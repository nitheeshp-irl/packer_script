#!/bin/bash

# URL of the GitHub repository
REPO_URL="https://github.com/nitheeshp-irl/packer_script.git"

# Path to the script inside the repository
SCRIPT_PATH_IN_REPO="/"

# Name of the script to download
TARGET_NAME="user-data.sh"

# Temporary directory to clone the repo
TEMP_DIR=$(mktemp -d)

# Ensure the script is run as root (since /opt typically requires root permissions)
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Check if git is available
if ! command -v git >/dev/null; then
    echo "Git is not available. Please install git and try again."
    exit 1
fi

# Clone the repository to a temporary directory
git clone "$REPO_URL" "$TEMP_DIR"

# Copy the desired script to /opt
cp "${TEMP_DIR}/${SCRIPT_PATH_IN_REPO}" "/opt/${TARGET_NAME}"

# Optional: Make the script executable
chmod +x "/opt/${TARGET_NAME}"

# Cleanup: remove the temporary directory
rm -rf "$TEMP_DIR"

echo "Script has been downloaded to /opt/${TARGET_NAME}"
