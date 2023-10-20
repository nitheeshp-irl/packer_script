#!/bin/bash

sudo exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# URL of the GitHub repository
REPO_URL="https://github.com/nitheeshp-irl/packer_script.git"

# Path to the script inside the repository (assuming it's at the root of the repo)
SCRIPT_PATH_IN_REPO="user-data.sh"

# Name of the script to download
TARGET_NAME="user-data.sh"

# User-Data Dir
USER_DATA_DIR="/var/lib/cloud/scripts/per-instance/"

# Temporary directory to clone the repo
TEMP_DIR=$(mktemp -d)

# Ensure the script is run as root (since ${USER_DATA_DIR} and installing software typically requires root permissions)
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Check if git is available
if ! command -v git >/dev/null; then
    echo "Git is not available. Attempting to install git..."

    # Determine the package manager and try to install git
    if command -v apt-get >/dev/null; then
        apt-get update
        apt-get install -y git
    elif command -v yum >/dev/null; then
        yum install -y git
    else
        echo "Error: Unable to determine package manager or install git. Please install git manually."
        exit 1
    fi
fi

# Clone the repository to a temporary directory
git clone "$REPO_URL" "$TEMP_DIR"

# Copy the desired script to user-data dir
cp "${TEMP_DIR}/${SCRIPT_PATH_IN_REPO}" "${USER_DATA_DIR}${TARGET_NAME}"

# Check if the file has been copied successfully
if [ ! -f "${USER_DATA_DIR}${TARGET_NAME}" ]; then
    echo "Error: Failed to copy the script to ${USER_DATA_DIR}"
    exit 1
fi

# Make the script executable
chmod +x "${USER_DATA_DIR}${TARGET_NAME}"

# Cleanup: remove the temporary directory
rm -rf "$TEMP_DIR"

echo "Script has been downloaded to ${USER_DATA_DIR}${TARGET_NAME}"
