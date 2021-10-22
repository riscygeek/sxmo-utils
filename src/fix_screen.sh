#!/bin/sh

# This script fixes the broken external video output on my Pinephone (Conergence, Beta Edition)
# Original forum post: https://forum.pine64.org/showthread.php?tid=15050

error() {
   echo "$(basename "$0"): $1" >&2
   exit 1
}

# Check if this script is run as root
[ $# -ne 1 ] && echo "Usage: $(basename "$0") (-l|<edid-name>)" >&2 && exit 1

# List all edid files
if [ "$1" = "-l" ]; then
   ls -1 "/etc/edid/" | sed 's/^\(.*\)\.bin$/\1/'
   exit
fi

# Check if run as root
[ "$(id -u)" != 0 ] && error "Superuser access required."

# Check for the path to the EDID firmware
if echo "$1" | grep -qF "/"; then
   # If $1 has a '/', then it's a path
   edid="$1"
   [ ! -f "${edid}" ] && error "$1: No such file"
else
   # Otherwise, it's a name
   edid="/etc/edid/$1.bin"
   [ ! -f "${edid}" ] && error "$1: No such file, please put your edid file into /etc/edid/"
fi

# Rotate the screen to landscape mode
xrandr -o right

# Wait for the screen to rotate
sleep 1

# Disable force-connect
echo off > /sys/kernel/debug/dri/1/HDMI-A-1/force

# Upload EDID firmware
cat "${edid}" > /sys/kernel/debug/dri/1/HDMI-A-1/edid_override

# Enable force-connect
echo on > /sys/kernel/debug/dri/1/HDMI-A-1/force

# Set the external display as primary and mirror the internal display
xrandr --output HDMI-1 --auto --primary --same-as DSI-1 

# Let xrandr do its thing
xrandr --auto

# TODO:
# - Fix wallpaper
# - Error handling
# - Check for more monitors
# - Intergrate with the rest of the Sxmo environment
