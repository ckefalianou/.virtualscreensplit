
# Virtual Screen Split

This is a bash script that allows you to quickly switch between different display configurations for your monitors. You can use it to set up a single monitor, split your monitor into virtual displays, or set up a dual monitor configuration. 

## Important note
Screen split is only available for x11 sessions for now. "Wayland" support is not its way 🚀

## Why use this?
When working with single Ultrawide screens, and you need to share your screen, it is really difficult for everyone to see. You need to switch share between windows and tabs, which is not efficient. Using this script, you will be able **to share a portion of your screen**,

## Features

- **Single Mode:** Sets your primary display to the full resolution and disables the second display.
- **Virtual Split Mode:** Splits your monitor into two virtual monitors.
- **Virtual Three Split Mode:** Splits your monitor into three virtual monitors. The middle one, is always 1920px.
- **Physical Dual Monitors:** Enables a physical dual monitor setup, placing the second monitor to the right of the primary display.

## Requirements

- `xrandr`: The script uses `xrandr` for managing displays, so it must be installed on your system.

## Script Breakdown

### Variables

- `PRIMARY_DISPLAY`: The primary display (e.g., DP-1). You can change it to match your system's display.
- `SECOND_DISPLAY`: The secondary display (e.g., HDMI-1). You can change it if your second monitor has a different name.
- `PRIMARY_RESOLUTION`: The resolution of your primary display is fetched dynamically using `xrandr`.
- `PRIMARY_WIDTH`, `PRIMARY_HEIGHT`: The width and height of the primary display.
- `HALF_WIDTH`: The width of half the primary display used for split modes.
- `MIDDLE_WIDTH`, `MIDDLE_THIRDS`, `THIRD_SCREEN_OFFSET`: These are used for the three-way virtual split mode. `MIDDLE_THIRDS` is always 1920px.

### Functions

- **remove_virtual_monitors**: Removes any existing virtual monitors to ensure a clean state before switching modes.
- **single_monitor**: Switches to a single ultrawide monitor by disabling the second display.
- **virtual_split**: Splits the monitor into two virtual monitors.
- **virtual_three_split**: Splits the monitor into three virtual monitors.

### Usage

1. Download or copy the script to a file on your system (e.g., `virtualscreensplit.sh`).
2. Navigate to that folder through Terminal
3. Make the script executable:
```bash
chmod +x virtualscreensplit.sh
```
4. Run the script
```bash
./virtualscreensplit.sh
```

### Test virtual screens
```
xrandr --listmonitors
```

