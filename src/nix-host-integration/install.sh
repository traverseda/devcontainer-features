#!/bin/bash
set -e

# Create necessary directories
mkdir -p /nix/var/nix/profiles/per-user
mkdir -p /nix/var/nix/gcroots/per-user

# Set up Nix configuration for daemon usage
mkdir -p /etc/nix
cat > /etc/nix/nix.conf << 'EOF'
build-users-group = nixbld
experimental-features = nix-command flakes
EOF

# Add Nix binaries to PATH
cat >> /etc/profile.d/nix.sh << 'EOF'
export PATH="/nix/var/nix/profiles/default/bin:$PATH"
export NIX_REMOTE=daemon
EOF

# Make profile script executable
chmod +x /etc/profile.d/nix.sh

# Source in current shell environments
echo 'source /etc/profile.d/nix.sh' >> /etc/bash.bashrc
echo 'source /etc/profile.d/nix.sh' >> /etc/zsh/zshrc 2>/dev/null || true

# Validate Nix accessibility
if [ -x "/nix/var/nix/profiles/default/bin/nix" ]; then
    echo "Nix is accessible via the host's store"
else
    echo "Warning: Nix binary not found at expected location"
fi
