#!/usr/bin/env bash
# Quick Wallpaper Selector for Niri
# Uses swaybg to set wallpapers

WALLPAPER_DIR="${HOME}/Pictures/Wallpapers"
CACHE_FILE="${HOME}/.cache/current-wallpaper"

# Get list of wallpapers
get_wallpapers() {
    find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null | sort
}

# Set wallpaper with swaybg
set_wallpaper() {
    local wallpaper="$1"
    
    # Kill existing swaybg instances
    pkill -x swaybg
    
    # Set new wallpaper
    swaybg -i "$wallpaper" -m fill &
    
    # Cache current wallpaper
    echo "$wallpaper" > "$CACHE_FILE"
    
    # Run wallust to update colors
    if command -v wallust &>/dev/null; then
        wallust run "$wallpaper" &
    fi
    
    notify-send "Wallpaper" "Set: $(basename "$wallpaper")" -i preferences-desktop-wallpaper
}

# Select wallpaper using fuzzel
select_wallpaper() {
    local wallpapers
    wallpapers=$(get_wallpapers)
    
    if [[ -z "$wallpapers" ]]; then
        notify-send "Wallpaper" "No wallpapers found in $WALLPAPER_DIR" -u critical
        exit 1
    fi
    
    local selected
    selected=$(echo "$wallpapers" | xargs -I{} basename {} | fuzzel --dmenu -p "Wallpaper: ")
    
    if [[ -n "$selected" ]]; then
        local full_path
        full_path=$(echo "$wallpapers" | grep -F "/$selected")
        if [[ -n "$full_path" ]]; then
            set_wallpaper "$full_path"
        fi
    fi
}

# Random wallpaper
random_wallpaper() {
    local wallpapers
    wallpapers=$(get_wallpapers)
    
    if [[ -z "$wallpapers" ]]; then
        notify-send "Wallpaper" "No wallpapers found in $WALLPAPER_DIR" -u critical
        exit 1
    fi
    
    local random_wp
    random_wp=$(echo "$wallpapers" | shuf -n 1)
    set_wallpaper "$random_wp"
}

# Restore last wallpaper
restore_wallpaper() {
    if [[ -f "$CACHE_FILE" ]]; then
        local last_wp
        last_wp=$(cat "$CACHE_FILE")
        if [[ -f "$last_wp" ]]; then
            set_wallpaper "$last_wp"
            return
        fi
    fi
    
    # Fall back to random if no cache
    random_wallpaper
}

# Main
case "${1:-select}" in
    select)
        select_wallpaper
        ;;
    random)
        random_wallpaper
        ;;
    restore)
        restore_wallpaper
        ;;
    *)
        echo "Usage: $0 {select|random|restore}"
        exit 1
        ;;
esac
