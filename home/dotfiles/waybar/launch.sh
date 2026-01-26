#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# 🔄 WAYBAR LAUNCHER & RESTART SCRIPT
# Clean restart of Waybar with error handling
# ═══════════════════════════════════════════════════════════════════

# Kill existing Waybar instances
pkill waybar 2>/dev/null

# Wait a moment for clean shutdown
sleep 0.5

# Check if config exists
if [ ! -f "$HOME/.config/waybar/config" ]; then
    echo "❌ Waybar config not found at $HOME/.config/waybar/config"
    notify-send -u critical "Waybar" "Config not found!"
    exit 1
fi

if [ ! -f "$HOME/.config/waybar/style.css" ]; then
    echo "❌ Waybar style not found at $HOME/.config/waybar/style.css"
    notify-send -u critical "Waybar" "Style not found!"
    exit 1
fi

# Launch Waybar in background
waybar -c "$HOME/.config/waybar/config" -s "$HOME/.config/waybar/style.css" &

# Check if it started successfully
sleep 1
if pgrep waybar >/dev/null; then
    echo "✅ Waybar started successfully"
else
    echo "❌ Waybar failed to start"
    notify-send -u critical "Waybar" "Failed to start!"
    exit 1
fi
