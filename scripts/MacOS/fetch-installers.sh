#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

# softwareupdate --list-full-installers
# diskutil list
# chmod +x bootlandia.sh

counter=0
subcounter=0
start_time=${SECONDS}

function new_step() {
    export counter=$((counter + 1))
    export subcounter=0
    echo ""
    echo "Step ${counter}: ${1}"
}

function sub_step() {
    export subcounter=$((subcounter + 1))
    echo ""
    echo "  Substep ${counter}.${subcounter}: ${1}"
}

function display_total_elapsed_time() {
    local total_elapsed_time=$((SECONDS - start_time))
    local total_minutes=$((total_elapsed_time / 60))
    local total_seconds=$((total_elapsed_time % 60))
    echo ""
    printf "Total elapsed time: %02d:%02d (MM:SS)\n" "$total_minutes" "$total_seconds"
}

###     ###     ###     ###     ###     ###     ###     ###     ###

new_step "softwareupdate --list-full-installers"
    softwareupdate --list-full-installers

new_step "Output directory for downloaded installers"
INSTALLER_DIR="$HOME/Downloads/macOS-installers"
mkdir -p "$INSTALLER_DIR"
cd "$INSTALLER_DIR" || exit 1

new_step "url: Ventura 13.6.5"
VENTURA_URL="https://swcdn.apple.com/content/downloads/55/52/042-19651-A_GJCRDCZ7SK/6d4dpk03f4c47qrczab8z8boq4qcb3m5m7/InstallAssistant.pkg"

new_step "url: Sonoma 14.4.1"
SONOMA_URL="https://swcdn.apple.com/content/downloads/07/41/042-94190-A_0P1I1KRIY4/cn2eh8yxf01fqzg99zho4g6s1zgb6aiv1k/InstallAssistant.pkg"

download_and_install() {
    local name="$1"
    local url="$2"

    sub_step "⬇️  Downloading $name installer..."
    curl -L -o "InstallAssistant-$name.pkg" "$url"

    sub_step "📦 Installing $name to /Applications..."
    sudo installer -pkg "InstallAssistant-$name.pkg" -target /
}

new_step "Ventura 13.6.5"
    download_and_install "Ventura" "$VENTURA_URL"

new_step "Sonoma 14.4.1"
    download_and_install "Sonoma" "$SONOMA_URL"

sub_step "✅ All done. Check /Applications for the .app installers."

display_total_elapsed_time
