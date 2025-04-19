#!/usr/bin/env bash 
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

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

new_step "diskutil list"
    diskutil list

# Prompt for disk selection
echo ""
new_step "Which disk is your external drive? (e.g., disk3)"
    read -p "Enter disk identifier: " DISK_ID

# Confirm selection
echo ""
echo "You selected: $DISK_ID"
    diskutil info /dev/$DISK_ID
echo ""
read -p "Is this correct? (y/n): " CONFIRM

if [[ $CONFIRM != "y" ]]; then
    echo "Aborting. Please run script again with correct disk."
    exit 1
fi

# After reading DISK_ID
new_step "Exclude system drives"
if [[ $DISK_ID == "disk0" ]] || [[ $DISK_ID == "disk1" ]]; then
    echo "Error: Cannot use disk0 or disk1 - these are likely system disks!"
    exit 1
fi

new_step "Unmount entire disk"
    diskutil unmountDisk force /dev/$DISK_ID

new_step "Destroy the container (if any)"
    diskutil apfs deleteContainer /dev/${DISK_ID}s2 || echo "  ➤ No APFS container to delete"

new_step "Erase and repartition the whole drive"
    diskutil partitionDisk /dev/$DISK_ID GPT JHFS+ temp 1GB

new_step "Partition layout"
declare -A LABELS=(
    ["15.3.2-Sequoia"]=96
    ["14.7.5-Sonoma"]=96
    ["13.7.5-Ventura"]=96
    ["12.7.4-Monterey"]=96
    ["11.7.10-Big-Sur"]=96
)

new_step "🛑 This will ERASE /dev/$DISK_ID. Press Ctrl+C to abort."
    read -p "Press [Enter] to continue..."

new_step "Build partition command string"
# "APFS disks may not be used as bootable install media"
PART_CMD=""
for LABEL in "${!LABELS[@]}"; do
    sub_step "SIZE=$SIZE"
    SIZE="${LABELS[$LABEL]}"
    sub_step "PART_CMD+=JHFS+ \"$LABEL\" ${SIZE}GB"
    PART_CMD+="JHFS+ \"$LABEL\" ${SIZE}GB "
done

new_step "💽 Erasing and partitioning /dev/$DISK_ID..."
eval diskutil partitionDisk /dev/$DISK_ID GPT JHFS+ temp 1GB $PART_CMD

new_step "Mount points for each partition"
for LABEL in "${!LABELS[@]}"; do
    PART_ID=$(diskutil list | grep "$LABEL" | awk '{print $NF}')
    if [ -n "$PART_ID" ]; then
        sub_step "Mounting $LABEL ($PART_ID)"
        diskutil mount "$PART_ID" >/dev/null 2>&1
    else
        sub_step "⚠️  Could not find partition for $LABEL"
    fi
done

new_step "✅ Done. You can now reboot and hold Option (⌥) to test bootable macOS versions."

display_total_elapsed_time
