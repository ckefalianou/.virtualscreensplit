#!/bin/bash

# Get the primary display name
PRIMARY_DISPLAY=$(xrandr | grep " connected primary" | awk '{print $1}')

if [ -z "$PRIMARY_DISPLAY" ]; then
    echo "Error: Could not detect primary display."
    exit 1
fi

# Get the secondary display names (if any)
SECOND_DISPLAY=$(xrandr | grep " connected" | awk '{print $1}' | grep -v "$PRIMARY_DISPLAY" || echo "")

PRIMARY_RESOLUTION=$(xrandr --current | grep -A1 "$PRIMARY_DISPLAY" | tail -n 1 | awk '{print $1}')
PRIMARY_WIDTH=$(echo $PRIMARY_RESOLUTION | cut -d 'x' -f 1)
PRIMARY_HEIGHT=$(echo $PRIMARY_RESOLUTION | cut -d 'x' -f 2)
HALF_WIDTH=$((PRIMARY_WIDTH / 2))
MIDDLE_WIDTH=1920  # Assuming a static middle section width, can be adjusted dynamically
MIDDLE_THIRDS=$(((PRIMARY_WIDTH - MIDDLE_WIDTH) / 2))
THIRD_SCREEN_OFFSET=$((PRIMARY_WIDTH - MIDDLE_THIRDS))

remove_virtual_monitors() {
    echo "Removing all possible virtual monitors..."
    xrandr --listmonitors | grep VIRTUAL | awk '{print $2}' | while read MONITOR; do
        xrandr --delmonitor "$MONITOR"
    done
}

# Function to set single monitor mode
single_monitor() {
    xrandr --output "$PRIMARY_DISPLAY" --mode ${PRIMARY_WIDTH}x${PRIMARY_HEIGHT} --primary
    if [ -n "$SECOND_DISPLAY" ]; then
        xrandr --output "$SECOND_DISPLAY" --off
    fi
    remove_virtual_monitors
    echo "Switched to Single Monitor (${PRIMARY_WIDTH}x${PRIMARY_HEIGHT})"
}

# Function to split monitor into two virtual monitors
virtual_split() {
    remove_virtual_monitors
    xrandr --setmonitor VIRTUAL1 ${HALF_WIDTH}/${PRIMARY_WIDTH}x${PRIMARY_HEIGHT}/${PRIMARY_HEIGHT}+0+0 "$PRIMARY_DISPLAY"
    xrandr --setmonitor VIRTUAL2 ${HALF_WIDTH}/${PRIMARY_WIDTH}x${PRIMARY_HEIGHT}/${PRIMARY_HEIGHT}+${HALF_WIDTH}+0 "$PRIMARY_DISPLAY"
    echo "Switched to Virtual Split Mode (2x ${HALF_WIDTH}x${PRIMARY_HEIGHT})"
}

# Function to split monitor into three virtual monitors
virtual_three_split() {
    remove_virtual_monitors
    xrandr --setmonitor VIRTUAL1 ${MIDDLE_THIRDS}/${PRIMARY_WIDTH}x${PRIMARY_HEIGHT}/${PRIMARY_HEIGHT}+0+0 "$PRIMARY_DISPLAY"
    xrandr --setmonitor VIRTUAL2 ${MIDDLE_WIDTH}/${PRIMARY_WIDTH}x${PRIMARY_HEIGHT}/${PRIMARY_HEIGHT}+${MIDDLE_THIRDS}+0 "$PRIMARY_DISPLAY"
    xrandr --setmonitor VIRTUAL3 ${MIDDLE_THIRDS}/${PRIMARY_WIDTH}x${PRIMARY_HEIGHT}/${PRIMARY_HEIGHT}+${THIRD_SCREEN_OFFSET}+0 "$PRIMARY_DISPLAY"
    echo "Switched to Virtual Three Split Mode (${MIDDLE_THIRDS}x${PRIMARY_HEIGHT} | ${MIDDLE_WIDTH}x${PRIMARY_HEIGHT} | ${MIDDLE_THIRDS}x${PRIMARY_HEIGHT})"
}

# Display menu
echo "Choose a display mode:"
echo "1) Single Monitor (${PRIMARY_WIDTH}x${PRIMARY_HEIGHT})"
echo "2) Virtual Split Mode (2x ${HALF_WIDTH}x${PRIMARY_HEIGHT})"
echo "3) Virtual Three Split Mode (${MIDDLE_THIRDS}x${PRIMARY_HEIGHT} | ${MIDDLE_WIDTH}x${PRIMARY_HEIGHT} | ${MIDDLE_THIRDS}x${PRIMARY_HEIGHT})"
echo "4) Delete All Virtual Monitors"
read -p "Enter your choice (1/2/3/4): " choice

case $choice in
    1) single_monitor ;;
    2) virtual_split ;;
    3) virtual_three_split ;;
    4) remove_virtual_monitors ;;
    *) echo "Invalid choice, exiting." ;;
esac