#!/bin/bash

# Get the primary display name
PRIMARY_DISPLAY="DP-1"
SECOND_DISPLAY="HDMI-1" # Change this if your second monitor has a different name

PRIMARY_RESOLUTION=$(xrandr --current | grep -A1 "$PRIMARY_DISPLAY" | tail -n 1 | awk '{print $1}')
PRIMARY_WIDTH=$(echo $PRIMARY_RESOLUTION | cut -d 'x' -f 1) #${PRIMARY_WIDTH}
PRIMARY_HEIGHT=$(echo $PRIMARY_RESOLUTION | cut -d 'x' -f 2) #${PRIMARY_HEIGHT}
HALF_WIDTH=$((PRIMARY_WIDTH / 2)) #${HALF_WIDTH}
MIDDLE_WIDTH=$(( 1920 + 0 ))
MIDDLE_THIRDS=$(( (PRIMARY_WIDTH - MIDDLE_WIDTH) / 2 ))
THIRD_SCREEN_OFFSET=$((PRIMARY_WIDTH - MIDDLE_THIRDS))

remove_virtual_monitors() {
    xrandr --delmonitor VIRTUAL1 2>/dev/null
    xrandr --delmonitor VIRTUAL2 2>/dev/null
    xrandr --delmonitor VIRTUAL3 2>/dev/null
}

# Function to set single ultrawide mode
single_monitor() {
    xrandr --output $PRIMARY_DISPLAY --mode ${PRIMARY_WIDTH}x${PRIMARY_HEIGHT} --primary --output $SECOND_DISPLAY --off
    remove_virtual_monitors
    echo "Switched to Single Ultrawide Monitor (${PRIMARY_WIDTH}x${PRIMARY_HEIGHT})"
}

# Function to split ultrawide into two virtual monitors
virtual_split() {
    remove_virtual_monitors
    xrandr --setmonitor VIRTUAL1 ${HALF_WIDTH}/${PRIMARY_WIDTH}x${PRIMARY_HEIGHT}/${PRIMARY_HEIGHT}+0+0 $PRIMARY_DISPLAY
    xrandr --setmonitor VIRTUAL2 ${HALF_WIDTH}/${PRIMARY_WIDTH}x${PRIMARY_HEIGHT}/${PRIMARY_HEIGHT}+${HALF_WIDTH}+0 none
    echo "Switched to Virtual Split Mode (2x ${HALF_WIDTH}x${PRIMARY_HEIGHT})"
}

# Function to split ultrawide into three virtual monitors
virtual_three_split() {
    remove_virtual_monitors
    xrandr --setmonitor VIRTUAL1 ${MIDDLE_THIRDS}/${PRIMARY_WIDTH}x${PRIMARY_HEIGHT}/${PRIMARY_HEIGHT}+0+0 $PRIMARY_DISPLAY
    xrandr --setmonitor VIRTUAL2 ${MIDDLE_WIDTH}/${PRIMARY_WIDTH}x${PRIMARY_HEIGHT}/${PRIMARY_HEIGHT}+${MIDDLE_THIRDS}+0 none
    xrandr --setmonitor VIRTUAL3 ${MIDDLE_THIRDS}/${PRIMARY_WIDTH}x${PRIMARY_HEIGHT}/${PRIMARY_HEIGHT}+${THIRD_SCREEN_OFFSET}+0 none
    echo "Switched to Virtual Three Split Mode (${MIDDLE_THIRDS}x${PRIMARY_HEIGHT} | ${MIDDLE_WIDTH}x${PRIMARY_HEIGHT} | ${MIDDLE_THIRDS}x${PRIMARY_HEIGHT})"
}

# Function to enable physical dual monitors
physical_dual() {
    remove_virtual_monitors
    xrandr --output $PRIMARY_DISPLAY --primary --auto --output $SECOND_DISPLAY --auto --right-of $PRIMARY_DISPLAY
    echo "Switched to Physical Dual Monitor Setup"
}

# Display menu
echo "Choose a display mode:"
echo "1) Single Ultrawide Monitor (${PRIMARY_WIDTH}x${PRIMARY_HEIGHT})"
echo "2) Virtual Split Mode (2x ${HALF_WIDTH}x${PRIMARY_HEIGHT})"
echo "3) Virtual Three Split Mode (${MIDDLE_THIRDS}x${PRIMARY_HEIGHT} | ${MIDDLE_WIDTH}x${PRIMARY_HEIGHT} | ${MIDDLE_THIRDS}x${PRIMARY_HEIGHT})"
echo "4) Physical Dual Monitors"
read -p "Enter your choice (1/2/3/4): " choice

case $choice in
    1) single_monitor ;;
    2) virtual_split ;;
    3) virtual_three_split ;;
    4) physical_dual ;;
    *) echo "Invalid choice, exiting." ;;
esac
