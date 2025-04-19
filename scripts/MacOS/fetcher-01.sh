#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

# chmod +x fetcher-01.sh

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

new_step "declare -A VERSIONS"
declare -A VERSIONS
VERSIONS=(
    ["Sequoia"]="15.4"
    ["Sonoma"]="14.7.5"
    ["Ventura"]="13.7.5"
    ["Monterey"]="12.7.4"
    ["BigSur"]="11.7.10"
)

for os in "${!VERSIONS[@]}"; do
    version="${VERSIONS[$os]}"
    sub_step "Fetching macOS $os ($version)"
    softwareupdate --fetch-full-installer --full-installer-version "$version"
done

display_total_elapsed_time
