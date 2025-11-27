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

# Add UV to PATH for all users
# The UV installer typically installs to ~/.cargo/bin
# Make sure it's available for all users
for user_home in /root /home/*; do
    if [ -d "${user_home}" ]; then
        user_dir="${user_home}/.cargo/bin"
        if [ -d "${user_dir}" ]; then
            echo "export PATH=\"${user_dir}:\${PATH}\"" >> "${user_home}/.bashrc"
            if [ -f "${user_home}/.zshrc" ]; then
                echo "export PATH=\"${user_dir}:\${PATH}\"" >> "${user_home}/.zshrc"
            fi
        fi
    fi
done

# Also add to global profile
echo 'export PATH="${HOME}/.cargo/bin:${PATH}"' >> /etc/profile.d/uv.sh
chmod +x /etc/profile.d/uv.sh

echo "Done!"
