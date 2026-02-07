#!/usr/bin/env bash

# Cava visualizer for Waybar
# Synced with custom/music module - both check every 2 seconds
# - Green when playing
# - Grey when paused  
# - Hidden when no music player (spotify/ncspot) is running

# Prevent multiple instances
LOCKFILE="/tmp/waybar-cava.lock"
exec 200>"$LOCKFILE"
flock -n 200 || exit 0

trap 'rm -f "$LOCKFILE"' EXIT

# Cache variables for player status (check every ~2 seconds like music module)
CACHED_CLASS="hidden"
LAST_CHECK=0
CHECK_INTERVAL=2

update_player_status() {
    local now=$(date +%s)
    if (( now - LAST_CHECK >= CHECK_INTERVAL )); then
        LAST_CHECK=$now
        
        # Find spotify or ncspot player (same as music-player.sh)
        local PLAYER=$(playerctl -l 2>/dev/null | grep -E "spotify|ncspot" | head -1)
        
        if [[ -z "$PLAYER" ]]; then
            CACHED_CLASS="hidden"
            return
        fi
        
        local status=$(playerctl -p "$PLAYER" status 2>/dev/null)
        
        if [[ "$status" == "Playing" ]]; then
            CACHED_CLASS="playing"
        elif [[ "$status" == "Paused" ]]; then
            CACHED_CLASS="paused"
        else
            CACHED_CLASS="hidden"
        fi
    fi
}

cava -p ~/.config/cava/config_waybar | while read -r line; do
    update_player_status
    
    # Convert cava output to unicode bars
    bars=$(echo "$line" | sed 's/;//g;s/0/▁/g;s/1/▂/g;s/2/▃/g;s/3/▄/g;s/4/▅/g;s/5/▆/g;s/6/▇/g;s/7/█/g')
    
    if [[ "$CACHED_CLASS" == "hidden" ]]; then
        echo '{"text": "", "class": "hidden"}'
    else
        echo "{\"text\": \"$bars\", \"class\": \"$CACHED_CLASS\"}"
    fi
done
