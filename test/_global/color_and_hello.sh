#!/bin/bash

# The 'test/_global' folder is a special test folder that is not tied to a single feature.
#
# This test file is executed against a running container constructed
# from the value of 'nix_integration_with_common_utils' in the tests/_global/scenarios.json file.
#
# The value of a scenarios element is any properties available in the 'devcontainer.json'.
# Scenarios are useful for testing specific options in a feature, or to test a combination of features.
# 
# This test can be run with the following command (from the root of this repo)
#    devcontainer features test --global-scenarios-only .

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Test that common-utils features are installed
check "zsh-installed" command -v zsh

# Test nix integration
check "nix-store-mounted" test -d /nix/store
check "nix-remote-set" bash -c 'echo $NIX_REMOTE' | grep daemon

# Check if nix command is available
if command -v nix >/dev/null 2>&1; then
    check "nix-command-available" command -v nix
    check "nix-version" nix --version
else
    # Try to find nix in profile
    if [ -x "/nix/var/nix/profiles/default/bin/nix" ]; then
        check "nix-command-available-from-profile" test -x /nix/var/nix/profiles/default/bin/nix
    fi
fi

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
