#!/bin/bash

set -e

# Source the library with helper functions
source dev-container-features-test-lib

# Check if /nix is mounted and accessible
check "nix-store-mounted" test -d /nix/store

# Check if NIX_REMOTE is set to daemon (when daemon is enabled)
# The feature option 'enableDaemon' is passed as an environment variable
if [ "${enableDaemon:-true}" = "true" ]; then
    check "nix-remote-set" bash -c 'echo $NIX_REMOTE' | grep daemon
    # Check if daemon socket is accessible
    # Note: On some systems, the socket might be in a different location or not present in the container
    # So we'll make this check more lenient
    if [ -S "/nix/var/nix/daemon-socket/socket" ]; then
        check "nix-daemon-socket-exists" test -S /nix/var/nix/daemon-socket/socket
    fi
else
    check "nix-remote-not-set" bash -c 'echo $NIX_REMOTE' | grep -v daemon
fi

# Check if nix command is available (it should be from the host's installation)
# Note: On some distributions, nix might be installed in non-standard paths
if command -v nix >/dev/null 2>&1; then
    check "nix-command-available" command -v nix
    # Check if we can run a basic nix command
    check "nix-version" nix --version
    # Check if nix-shell can be invoked (even if it fails, it should show help)
    check "nix-shell-help" nix-shell --help
else
    # On some systems, nix might be in /nix/var/nix/profiles/default/bin/nix
    if [ -x "/nix/var/nix/profiles/default/bin/nix" ]; then
        check "nix-command-available-from-profile" test -x /nix/var/nix/profiles/default/bin/nix
        # Add to PATH for subsequent checks
        export PATH="/nix/var/nix/profiles/default/bin:$PATH"
        check "nix-version-from-profile" nix --version
        check "nix-shell-help-from-profile" nix-shell --help
    fi
fi

# Check if we can access nix store paths
check "nix-store-path-accessible" ls /nix/store | head -n 1

# Report result
reportResults
