#!/bin/bash

# Get the primary display name
PRIMARY_DISPLAY=$(xrandr | grep " connected" | awk '{print $1}')
SECOND_DISPLAY="HDMI-1" # Change this if your second monitor has a different name

# Get the screen resolution
SCREEN_RESOLUTION=$(xrandr | grep "*" | awk '{print $1}')
WIDTH=$(echo $SCREEN_RESOLUTION | cut -d 'x' -f1)
HEIGHT=$(echo $SCREEN_RESOLUTION | cut -d 'x' -f2)

# Function to remove existing virtual monitors safely
remove_virtual_monitors() {
    xrandr --delmonitor VIRTUAL1 2>/dev/null
    xrandr --delmonitor VIRTUAL2 2>/dev/null
    xrandr --delmonitor VIRTUAL3 2>/dev/null
}

# Function to set single ultrawide mode
single_monitor() {
    remove_virtual_monitors
    xrandr --output $PRIMARY_DISPLAY --mode ${WIDTH}x${HEIGHT} --primary --output $SECOND_DISPLAY --off
    echo "Switched to Single Ultrawide Monitor (${WIDTH}x${HEIGHT})"
}

# Function to split ultrawide into two virtual monitors
virtual_split() {
    remove_virtual_monitors
    HALF_WIDTH=$((WIDTH / 2))
    xrandr --setmonitor VIRTUAL1 ${HALF_WIDTH}/${WIDTH}x${HEIGHT}/${HEIGHT}+0+0 $PRIMARY_DISPLAY
    xrandr --setmonitor VIRTUAL2 ${HALF_WIDTH}/${WIDTH}x${HEIGHT}/${HEIGHT}+${HALF_WIDTH}+0 none
    echo "Switched to Virtual Split Mode (2x ${HALF_WIDTH}x${HEIGHT})"
}

# Function to split ultrawide into three virtual monitors
virtual_three_split() {
    remove_virtual_monitors
    MID_WIDTH=1920
    SIDE_WIDTH=$(((WIDTH - MID_WIDTH) / 2))
    xrandr --setmonitor VIRTUAL1 ${SIDE_WIDTH}/${WIDTH}x${HEIGHT}/${HEIGHT}+0+0 $PRIMARY_DISPLAY
    xrandr --setmonitor VIRTUAL2 ${MID_WIDTH}/${WIDTH}x${HEIGHT}/${HEIGHT}+${SIDE_WIDTH}+0 none
    xrandr --setmonitor VIRTUAL3 ${SIDE_WIDTH}/${WIDTH}x${HEIGHT}/${HEIGHT}+$((${SIDE_WIDTH} + ${MID_WIDTH}))+0 none
    echo "Switched to Virtual Three Split Mode (${SIDE_WIDTH}x${HEIGHT} | ${MID_WIDTH}x${HEIGHT} | ${SIDE_WIDTH}x${HEIGHT})"
}

# Function to enable physical dual monitors
physical_dual() {
    remove_virtual_monitors
    xrandr --output $PRIMARY_DISPLAY --primary --auto --output $SECOND_DISPLAY --auto --right-of $PRIMARY_DISPLAY
    echo "Switched to Physical Dual Monitor Setup"
}

# Display menu
echo "Choose a display mode:"
echo "1) Single Ultrawide Monitor (${WIDTH}x${HEIGHT})"
echo "2) Virtual Split Mode (2x Half Width x ${HEIGHT})"
echo "3) Virtual Three Split Mode (Left | Center 1920px | Right)"
echo "4) Physical Dual Monitors"
read -p "Enter your choice (1/2/3/4): " choice

case $choice in
    1) single_monitor ;;
    2) virtual_split ;;
    3) virtual_three_split ;;
    4) physical_dual ;;
    *) echo "Invalid choice, exiting." ;;
esac
