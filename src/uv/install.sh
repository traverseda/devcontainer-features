#!/bin/bash
set -e

VERSION=${VERSION:-"latest"}

# Clean up
rm -rf /var/lib/apt/lists/*

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Check if version is "latest"
if [ "${VERSION}" = "latest" ]; then
    # Install the latest version
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    # Install a specific version
    curl -LsSf https://astral.sh/uv/install.sh | sh -s -- -v "${VERSION}"
fi

# The UV installer installs to /root/.cargo/bin by default when running as root
# Let's make it available system-wide
UV_INSTALL_DIR="/root/.cargo/bin"
if [ -d "${UV_INSTALL_DIR}" ]; then
    # Create a symlink in /usr/local/bin which is typically in the PATH
    ln -sf ${UV_INSTALL_DIR}/uv /usr/local/bin/uv
    # Ensure the directory is in PATH for all users
    echo "export PATH=\"${UV_INSTALL_DIR}:\$PATH\"" >> /etc/profile.d/uv.sh
    chmod +x /etc/profile.d/uv.sh
fi

echo "Done!"
