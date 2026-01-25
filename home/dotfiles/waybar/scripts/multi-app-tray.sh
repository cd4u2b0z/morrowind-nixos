#!/usr/bin/env bash
set -u
export LANG=C LC_ALL=C

# Dependency check
command -v hyprctl >/dev/null 2>&1 || { printf '{"text":"󰀻","tooltip":"hyprctl not found","class":"error"}\n'; exit 0; }
command -v jq >/dev/null 2>&1 || { printf '{"text":"󰀻","tooltip":"jq not found","class":"error"}\n'; exit 0; }

# Fetch window list ONCE (major optimization: 2 processes instead of ~30)
WINDOWS=$(hyprctl clients -j 2>/dev/null | jq -r '.[].class // empty' | tr '[:upper:]' '[:lower:]')

has_window() { echo "$WINDOWS" | grep -qx "$1"; }

apps=() classes=() names=()

# All checks use the cached $WINDOWS variable - no additional subprocess spawns
has_window "brave-browser" && { apps+=("󰣘"); classes+=("brave"); names+=("Brave"); }
has_window "librewolf" && { apps+=(""); classes+=("librewolf"); names+=("LibreWolf"); }
has_window "firefox" && { apps+=("󰈹"); classes+=("firefox"); names+=("Firefox"); }
has_window "code" && { apps+=("󰨞"); classes+=("vscode"); names+=("VS Code"); }
has_window "kitty" && { apps+=("󰄛"); classes+=("kitty"); names+=("Kitty"); }
has_window "thunar" && { apps+=("󰉋"); classes+=("thunar"); names+=("Thunar"); }
has_window "spotify" && { apps+=("󰓇"); classes+=("spotify"); names+=("Spotify"); }
pgrep -x ncspot >/dev/null 2>&1 && { apps+=(""); classes+=("ncspot"); names+=("ncspot"); }
has_window "discord" && { apps+=("󰙯"); classes+=("discord"); names+=("Discord"); }
has_window "steam" && { apps+=("󰓓"); classes+=("steam"); names+=("Steam"); }
(has_window "obs" || has_window "com.obsproject.studio") && { apps+=("󰑋"); classes+=("obs"); names+=("OBS"); }
has_window "gimp" && { apps+=("󰏘"); classes+=("gimp"); names+=("GIMP"); }
has_window "blender" && { apps+=("󰂫"); classes+=("blender"); names+=("Blender"); }

if [ ${#apps[@]} -eq 0 ]; then
    printf '{"text":"󰀻","tooltip":"No apps running","class":"empty"}\n'
else
    text=$(IFS='  '; echo "${apps[*]}")
    tooltip="${#apps[@]} running: $(IFS=', '; echo "${names[*]}")"
    class="${classes[*]}"
    printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text" "$tooltip" "$class"
fi
