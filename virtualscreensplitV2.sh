#!/bin/bash

# Detect if running on Wayland or X11
SESSION_TYPE=$(loginctl show-session $(awk '/tty/{print $1}' <(loginctl)) -p Type --value)

# Ensure required packages are installed based on SESSION_TYPE
if [ "$SESSION_TYPE" = "x11" ]; then
    REQUIRED_PACKAGES=(x11-xserver-utils)
elif [ "$SESSION_TYPE" = "wayland" ]; then
    REQUIRED_PACKAGES=(wlroots gamescope)
fi

MISSING_PACKAGES=()
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! dpkg -l | grep -q " $pkg "; then
        MISSING_PACKAGES+=("$pkg")
    fi
done

if [ ${#MISSING_PACKAGES[@]} -ne 0 ]; then
    echo "You are using '${SESSION_TYPE}'. Please install missing packages: ${MISSING_PACKAGES[*]}"
    exit
fi

# Get the primary display name based on session type
if [ "$SESSION_TYPE" = "x11" ]; then
    PRIMARY_DISPLAY=$(xrandr | grep " connected primary" | awk '{print $1}')
else
    PRIMARY_DISPLAY=$(wlr-randr | awk '/Output/ {print $2; exit}')
fi

if [ -z "$PRIMARY_DISPLAY" ]; then
    echo "Error: Could not detect primary display."
    exit 1
fi

echo "Primary Display: $PRIMARY_DISPLAY"

# Get the secondary display names (if any)
if [ "$SESSION_TYPE" = "x11" ]; then
    SECOND_DISPLAY=$(xrandr | grep " connected" | awk '{print $1}' | grep -v "$PRIMARY_DISPLAY" || echo "")
else
    SECOND_DISPLAY=""
fi

PRIMARY_RESOLUTION="1920x1080"  # Default resolution for Wayland fallback
if [ "$SESSION_TYPE" = "x11" ]; then
    PRIMARY_RESOLUTION=$(xrandr --current | grep -A1 "$PRIMARY_DISPLAY" | tail -n 1 | awk '{print $1}')
fi

PRIMARY_WIDTH=$(echo $PRIMARY_RESOLUTION | cut -d 'x' -f 1)
PRIMARY_HEIGHT=$(echo $PRIMARY_RESOLUTION | cut -d 'x' -f 2)
HALF_WIDTH=$((PRIMARY_WIDTH / 2))
MIDDLE_WIDTH=1920
MIDDLE_THIRDS=$(((PRIMARY_WIDTH - MIDDLE_WIDTH) / 2))
THIRD_SCREEN_OFFSET=$((PRIMARY_WIDTH - MIDDLE_THIRDS))

remove_virtual_monitors() {
    echo "Removing all possible virtual monitors..."
    if [ "$SESSION_TYPE" = "x11" ]; then
        xrandr --listmonitors | grep VIRTUAL | awk '{print $2}' | while read MONITOR; do
            xrandr --delmonitor "$MONITOR"
        done
    fi
}

single_monitor() {
    if [ "$SESSION_TYPE" = "x11" ]; then
        xrandr --output "$PRIMARY_DISPLAY" --mode ${PRIMARY_WIDTH}x${PRIMARY_HEIGHT} --primary
        if [ -n "$SECOND_DISPLAY" ]; then
            xrandr --output "$SECOND_DISPLAY" --off
        fi
    else
        gamescope -W $PRIMARY_WIDTH -H $PRIMARY_HEIGHT -- xterm &
    fi
    remove_virtual_monitors
    echo "Switched to Single Ultrawide Monitor (${PRIMARY_WIDTH}x${PRIMARY_HEIGHT})"
}

virtual_split() {
    remove_virtual_monitors
    if [ "$SESSION_TYPE" = "x11" ]; then
        xrandr --setmonitor VIRTUAL1 ${HALF_WIDTH}/${PRIMARY_WIDTH}x${PRIMARY_HEIGHT}/${PRIMARY_HEIGHT}+0+0 "$PRIMARY_DISPLAY"
        xrandr --setmonitor VIRTUAL2 ${HALF_WIDTH}/${PRIMARY_WIDTH}x${PRIMARY_HEIGHT}/${PRIMARY_HEIGHT}+${HALF_WIDTH}+0 "$PRIMARY_DISPLAY"
    else
        gamescope -W $HALF_WIDTH -H $PRIMARY_HEIGHT -- xterm &
        gamescope -W $HALF_WIDTH -H $PRIMARY_HEIGHT -- xterm &
    fi
    echo "Switched to Virtual Split Mode (2x ${HALF_WIDTH}x${PRIMARY_HEIGHT})"
}

virtual_three_split() {
    remove_virtual_monitors
    if [ "$SESSION_TYPE" = "x11" ]; then
        xrandr --setmonitor VIRTUAL1 ${MIDDLE_THIRDS}/${PRIMARY_WIDTH}x${PRIMARY_HEIGHT}/${PRIMARY_HEIGHT}+0+0 "$PRIMARY_DISPLAY"
        xrandr --setmonitor VIRTUAL2 ${MIDDLE_WIDTH}/${PRIMARY_WIDTH}x${PRIMARY_HEIGHT}/${PRIMARY_HEIGHT}+${MIDDLE_THIRDS}+0 "$PRIMARY_DISPLAY"
        xrandr --setmonitor VIRTUAL3 ${MIDDLE_THIRDS}/${PRIMARY_WIDTH}x${PRIMARY_HEIGHT}/${PRIMARY_HEIGHT}+${THIRD_SCREEN_OFFSET}+0 "$PRIMARY_DISPLAY"
    else
        gamescope -W $MIDDLE_THIRDS -H $PRIMARY_HEIGHT -- xterm &
        gamescope -W $MIDDLE_WIDTH -H $PRIMARY_HEIGHT -- xterm &
        gamescope -W $MIDDLE_THIRDS -H $PRIMARY_HEIGHT -- xterm &
    fi
    echo "Switched to Virtual Three Split Mode (${MIDDLE_THIRDS}x${PRIMARY_HEIGHT} | ${MIDDLE_WIDTH}x${PRIMARY_HEIGHT} | ${MIDDLE_THIRDS}x${PRIMARY_HEIGHT})"
}

physical_dual() {
    remove_virtual_monitors
    if [ "$SESSION_TYPE" = "x11" ] && [ -n "$SECOND_DISPLAY" ]; then
        xrandr --output "$PRIMARY_DISPLAY" --primary --auto --output "$SECOND_DISPLAY" --auto --right-of "$PRIMARY_DISPLAY"
        echo "Switched to Physical Dual Monitor Setup"
    else
        echo "No secondary display detected or running on Wayland."
    fi
}

echo "Choose a display mode:"
echo "1) Single Ultrawide Monitor (${PRIMARY_WIDTH}x${PRIMARY_HEIGHT})"
echo "2) Virtual Split Mode (2x ${HALF_WIDTH}x${PRIMARY_HEIGHT})"
echo "3) Virtual Three Split Mode (${MIDDLE_THIRDS}x${PRIMARY_HEIGHT} | ${MIDDLE_WIDTH}x${PRIMARY_HEIGHT} | ${MIDDLE_THIRDS}x${PRIMARY_HEIGHT})"
echo "4) Physical Dual Monitors"
echo "5) Delete All Virtual Monitors"
read -p "Enter your choice (1/2/3/4/5): " choice

case $choice in
    1) single_monitor ;;
    2) virtual_split ;;
    3) virtual_three_split ;;
    4) physical_dual ;;
    5) remove_virtual_monitors ;;
    *) echo "Invalid choice, exiting." ;;
esac
