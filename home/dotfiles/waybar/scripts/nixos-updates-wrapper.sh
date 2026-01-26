#!/usr/bin/env bash
# NixOS Updates Wrapper for Waybar
# Shows NixOS icon, generation info in tooltip on hover

CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/nixos-updates/status"
CACHE_AGE=3600  # 1 hour

rm -f "$(dirname "$CACHE_FILE")" 2>/dev/null; mkdir -p "$(dirname "$CACHE_FILE")"

get_update_status() {
    local current_gen=$(readlink /nix/var/nix/profiles/system 2>/dev/null | grep -oP 'system-\K\d+' || echo "?")
    local gen_count=$(ls -1 /nix/var/nix/profiles/system-*-link 2>/dev/null | wc -l)
    local last_update=$(stat -c %Y /nix/var/nix/profiles/system 2>/dev/null)
    local last_update_human=""
    
    if [[ -n "$last_update" ]]; then
        last_update_human=$(date -d "@$last_update" "+%Y-%m-%d %H:%M")
    fi
    
    # Empty text (icon only), info in tooltip
    echo "{\"text\": \"\", \"tooltip\": \"󱄅 NixOS Generation $current_gen\\n\\nTotal generations: $gen_count\\nLast rebuild: $last_update_human\\n\\nClick: Update manager\\nRight-click: Rebuild now\", \"class\": \"nixos\"}"
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
