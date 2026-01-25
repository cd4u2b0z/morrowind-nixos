#!/usr/bin/env bash
# NixOS Update Checker for Waybar
# Displays number of available updates in NixOS

CACHE_FILE="$HOME/.cache/nixos-updates"
CACHE_AGE_LIMIT=3600  # 1 hour

get_updates() {
    # Check if we can get updates from nix-channel
    if command -v nix-channel &>/dev/null; then
        # Get system generation info
        local current_gen=$(readlink /run/current-system)
        local update_count=0
        
        # Check for flake.lock changes (if using flakes)
        if [[ -f /etc/nixos/flake.lock ]]; then
            # Check if flake inputs have updates
            # This is a simplified check
            update_count=$(nix flake metadata /etc/nixos 2>/dev/null | grep -c "Updated" || echo "0")
        fi
        
        echo "$update_count"
    else
        echo "0"
    fi
}

# Check cache age
if [[ -f "$CACHE_FILE" ]]; then
    cache_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [[ $cache_age -lt $CACHE_AGE_LIMIT ]]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Get updates and cache
updates=$(get_updates)
echo "$updates" > "$CACHE_FILE"

# Output for Waybar
if [[ "$updates" -gt 0 ]]; then
    echo "{\"text\": \"󰚰 $updates\", \"tooltip\": \"$updates updates available\", \"class\": \"pending\"}"
else
    echo "{\"text\": \"󰄬\", \"tooltip\": \"System is up to date\", \"class\": \"updated\"}"
fi
