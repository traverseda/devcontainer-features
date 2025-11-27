#!/bin/bash

set -e

# Source the library with helper functions
source dev-container-features-test-lib

# Check if nix command is available
check "nix-command-available" command -v nix

# Check if NIX_REMOTE is set to daemon
check "nix-remote-set" bash -c 'echo $NIX_REMOTE' | grep daemon

# Check if we can run a basic nix command
check "nix-version" nix --version

# Check if nix-shell can be invoked (even if it fails, it should show help)
check "nix-shell-help" nix-shell --help

# Check if /nix is mounted and accessible
check "nix-store-mounted" test -d /nix/store

# Check if daemon socket is accessible (if enabled)
if [ "${ENABLE_DAEMON:-true}" = "true" ]; then
    check "nix-daemon-socket" test -S /nix/var/nix/daemon-socket/socket
fi

# Report result
reportResults
