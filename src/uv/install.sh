#!/bin/sh
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

# Add UV to PATH for all users
echo 'export PATH="${HOME}/.cargo/bin:${PATH}"' | tee -a /etc/bash.bashrc >> /etc/profile
if [ -d /etc/zsh/zshrc ]; then
    echo 'export PATH="${HOME}/.cargo/bin:${PATH}"' >> /etc/zsh/zshrc
fi

echo "Done!"
