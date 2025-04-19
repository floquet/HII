#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

# Create download directory
INSTALLER_DIR="$HOME/Downloads/macOS-installers"
mkdir -p "$INSTALLER_DIR"
cd "$INSTALLER_DIR" || exit 1

# Direct download URLs (these need to be current)
SEQUOIA_URL="[appropriate URL for 15.3.2]"

# Download and install
echo "Downloading Sequoia installer..."
curl -L -o "InstallAssistant-Sequoia.pkg" "$SEQUOIA_URL"

echo "Installing Sequoia (requires sudo)..."
sudo installer -pkg "InstallAssistant-Sequoia.pkg" -target /

echo "Done. Check /Applications for the installer."
