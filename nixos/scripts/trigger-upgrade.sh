#!/usr/bin/env bash
set -euo pipefail

# Script to trigger nixos upgrade from GitHub Actions
echo "Triggering NixOS upgrade..."

# Try multiple approaches
if systemctl start --wait nixos-upgrade.service; then
    echo "Successfully started nixos-upgrade.service"
elif sudo systemctl start --wait nixos-upgrade.service; then
    echo "Successfully started nixos-upgrade.service with sudo"
elif systemctl start nixos-upgrade.timer; then
    echo "Started nixos-upgrade.timer instead"
else
    echo "Failed to start upgrade service or timer"
    exit 1
fi
