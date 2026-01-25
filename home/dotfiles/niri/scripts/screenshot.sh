#!/usr/bin/env bash
# Screenshot helper for Niri using grimshot/grim

SCREENSHOT_DIR="${HOME}/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME="${SCREENSHOT_DIR}/screenshot_${TIMESTAMP}.png"

case "${1:-area}" in
    area)
        # Interactive selection
        grim -g "$(slurp)" "$FILENAME" && \
            wl-copy < "$FILENAME" && \
            notify-send "Screenshot" "Area saved and copied to clipboard" -i applets-screenshooter
        ;;
    screen)
        # Full screen
        grim "$FILENAME" && \
            wl-copy < "$FILENAME" && \
            notify-send "Screenshot" "Screen saved and copied to clipboard" -i applets-screenshooter
        ;;
    window)
        # Current window (uses slurp with window geometry)
        # For Niri, we use active window geometry
        grim -g "$(slurp -o)" "$FILENAME" && \
            wl-copy < "$FILENAME" && \
            notify-send "Screenshot" "Window saved and copied to clipboard" -i applets-screenshooter
        ;;
    *)
        echo "Usage: $0 {area|screen|window}"
        exit 1
        ;;
esac
