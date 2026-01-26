#!/usr/bin/env bash
# NixOS Updates Wrapper for Waybar
# Shows update status in waybar module

CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/nixos-updates/status"
CACHE_AGE=3600  # 1 hour

mkdir -p "$(dirname "$CACHE_FILE")"

get_update_status() {
    local current_gen=$(readlink /nix/var/nix/profiles/system 2>/dev/null | grep -oP 'system-\K\d+' || echo "?")
    local gen_count=$(ls -1 /nix/var/nix/profiles/system-*-link 2>/dev/null | wc -l)
    
    # Simple status - just show generation info
    echo "{\"text\": \"Gen $current_gen\", \"tooltip\": \"NixOS Generation: $current_gen\\nTotal generations: $gen_count\\nClick to manage updates\", \"class\": \"nixos\"}"
}

# Check cache
if [[ -f "$CACHE_FILE" ]]; then
    cache_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [[ $cache_age -lt $CACHE_AGE ]]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Generate and cache status
status=$(get_update_status)
echo "$status" > "$CACHE_FILE"
echo "$status"
