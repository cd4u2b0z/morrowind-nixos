#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
# NixOS + Niri System Validation Script
# Run this after installation to verify everything is working
# ═══════════════════════════════════════════════════════════════════════════

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASS=0
FAIL=0
WARN=0

# Helper functions
pass() {
    echo -e "${GREEN}✅ $1${NC}"
    ((PASS++))
}

fail() {
    echo -e "${RED}❌ $1${NC}"
    ((FAIL++))
}

warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARN++))
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

header() {
    echo ""
    echo -e "${BLUE}── $1 ──${NC}"
}

# Test functions
test_cmd() {
    if command -v "$1" &>/dev/null; then
        pass "$1 is installed"
    else
        fail "$1 is NOT installed"
    fi
}

test_cmd_optional() {
    if command -v "$1" &>/dev/null; then
        pass "$1 is installed"
    else
        warn "$1 is not installed (optional)"
    fi
}

test_service() {
    if systemctl is-active --quiet "$1" 2>/dev/null; then
        pass "$1 service is running"
    else
        fail "$1 service is NOT running"
    fi
}

test_user_service() {
    if systemctl --user is-active --quiet "$1" 2>/dev/null; then
        pass "$1 user service is running"
    else
        fail "$1 user service is NOT running"
    fi
}

test_file() {
    if [[ -f "$1" ]]; then
        pass "$(basename "$1") exists"
    else
        fail "$(basename "$1") is missing ($1)"
    fi
}

test_dir() {
    if [[ -d "$1" ]]; then
        pass "$(basename "$1") directory exists"
    else
        fail "$(basename "$1") directory is missing ($1)"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════
# Main Script
# ═══════════════════════════════════════════════════════════════════════════

echo ""
echo "═══════════════════════════════════════════════════════════════════════════"
echo "  NixOS + Niri System Validation"
echo "  $(date)"
echo "═══════════════════════════════════════════════════════════════════════════"

# System Info
header "System Information"
if command -v fastfetch &>/dev/null; then
    fastfetch --logo none --structure OS:Kernel:CPU:GPU:Memory 2>/dev/null || true
elif command -v neofetch &>/dev/null; then
    neofetch --off 2>/dev/null || true
else
    echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo "Kernel: $(uname -r)"
fi

# Core Applications
header "Core Applications"
test_cmd niri
test_cmd waybar
test_cmd kitty
test_cmd fuzzel
test_cmd mako
test_cmd swaylock
test_cmd swaybg
test_cmd grim
test_cmd slurp
test_cmd wl-copy
test_cmd brightnessctl

# Development Tools
header "Development Tools"
test_cmd git
test_cmd nvim
test_cmd_optional code
test_cmd_optional python3
test_cmd_optional node

# File Managers & Utils
header "Utilities"
test_cmd thunar
test_cmd btop
test_cmd_optional fastfetch

# System Services
header "System Services"
test_service NetworkManager
test_service bluetooth
test_service tlp

# User Services (if in graphical session)
if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    header "User Services (Wayland session detected)"
    test_user_service pipewire
    test_user_service pipewire-pulse
    test_user_service mako
else
    header "User Services"
    info "Not in Wayland session - skipping user service checks"
    info "Run this script from within Niri for full validation"
fi

# Configuration Files
header "Configuration Files"
test_file ~/.config/niri/config.kdl
test_file ~/.config/waybar/config
test_file ~/.config/waybar/style.css
test_file ~/.config/kitty/kitty.conf
test_file ~/.config/mako/config
test_file ~/.config/fuzzel/fuzzel.ini
test_file ~/.config/swaylock/config
test_file ~/.config/starship.toml

# Scripts
header "Niri Scripts"
test_file ~/.config/niri/scripts/quick-wallpaper.sh
test_file ~/.config/niri/scripts/screenshot.sh
test_file ~/.config/niri/scripts/theme-switcher.sh

header "Waybar Scripts"
test_file ~/.config/waybar/scripts/system-stats.sh
test_file ~/.config/waybar/scripts/bulletproof-weather.sh
test_file ~/.config/waybar/scripts/music-player.sh

# Hardware Checks
header "Hardware Detection"

# GPU
if lspci 2>/dev/null | grep -qi "intel.*graphics\|intel.*uhd\|intel.*iris"; then
    pass "Intel GPU detected"
elif lspci 2>/dev/null | grep -qi "amd.*radeon\|amd.*graphics"; then
    pass "AMD GPU detected"
elif lspci 2>/dev/null | grep -qi "nvidia"; then
    warn "NVIDIA GPU detected (may need additional config)"
else
    warn "GPU not clearly detected"
fi

# Audio
if command -v pactl &>/dev/null && pactl info &>/dev/null 2>&1; then
    pass "PipeWire audio is working"
    AUDIO_SINK=$(pactl get-default-sink 2>/dev/null || echo "unknown")
    info "Default audio sink: $AUDIO_SINK"
else
    fail "Audio system not responding"
fi

# Network
if ping -c 1 -W 2 1.1.1.1 &>/dev/null; then
    pass "Network is connected (internet access)"
elif ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
    pass "Network is connected (internet access)"
else
    fail "No internet connection"
fi

# WiFi interface
if iw dev 2>/dev/null | grep -q Interface; then
    pass "WiFi interface detected"
else
    warn "No WiFi interface detected (may be OK if using Ethernet)"
fi

# Battery (for laptops)
if [[ -d /sys/class/power_supply/BAT0 ]] || [[ -d /sys/class/power_supply/BAT1 ]]; then
    BATTERY_STATUS=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1)
    BATTERY_CAPACITY=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1)
    pass "Battery detected: ${BATTERY_CAPACITY}% (${BATTERY_STATUS})"
else
    info "No battery detected (desktop or not exposed)"
fi

# NixOS Specific
header "NixOS Configuration"

if [[ -f /etc/nixos/flake.nix ]]; then
    pass "Flake configuration found"
else
    warn "No flake.nix in /etc/nixos (may be elsewhere)"
fi

if [[ -L /run/current-system ]]; then
    NIXOS_VERSION=$(cat /run/current-system/nixos-version 2>/dev/null || echo "unknown")
    pass "NixOS system: $NIXOS_VERSION"
else
    fail "Not running NixOS?"
fi

# Check generations
GENERATIONS=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system 2>/dev/null | wc -l || echo "0")
info "System generations: $GENERATIONS"

# Niri Validation
header "Niri Configuration Check"

if command -v niri &>/dev/null; then
    if niri validate 2>&1 | grep -q "Config is valid\|Successfully parsed"; then
        pass "Niri config is valid"
    elif niri validate &>/dev/null; then
        pass "Niri config validates successfully"
    else
        fail "Niri config has errors - run 'niri validate' for details"
    fi
fi

# Disk Space
header "Disk Space"
ROOT_USAGE=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
ROOT_AVAIL=$(df -h / | awk 'NR==2 {print $4}')
if [[ $ROOT_USAGE -lt 80 ]]; then
    pass "Root filesystem: ${ROOT_USAGE}% used (${ROOT_AVAIL} available)"
elif [[ $ROOT_USAGE -lt 90 ]]; then
    warn "Root filesystem: ${ROOT_USAGE}% used (${ROOT_AVAIL} available)"
else
    fail "Root filesystem nearly full: ${ROOT_USAGE}% used"
fi

NIX_USAGE=$(df -h /nix 2>/dev/null | awk 'NR==2 {print $5}' | tr -d '%' || echo "0")
if [[ $NIX_USAGE -gt 0 ]]; then
    NIX_AVAIL=$(df -h /nix | awk 'NR==2 {print $4}')
    if [[ $NIX_USAGE -lt 80 ]]; then
        pass "Nix store: ${NIX_USAGE}% used (${NIX_AVAIL} available)"
    else
        warn "Nix store: ${NIX_USAGE}% used - consider 'nix-collect-garbage'"
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════════════════════════

echo ""
echo "═══════════════════════════════════════════════════════════════════════════"
echo -e "  Results: ${GREEN}$PASS passed${NC}, ${YELLOW}$WARN warnings${NC}, ${RED}$FAIL failed${NC}"
echo "═══════════════════════════════════════════════════════════════════════════"

if [[ $FAIL -eq 0 ]]; then
    if [[ $WARN -eq 0 ]]; then
        echo -e "${GREEN}🎉 All tests passed! Your system is fully ready.${NC}"
    else
        echo -e "${GREEN}✅ Core tests passed!${NC} ${YELLOW}Review warnings above.${NC}"
    fi
    exit 0
else
    echo -e "${RED}⚠️  Some tests failed. Review the issues above.${NC}"
    echo ""
    echo "Common fixes:"
    echo "  - Missing packages: Edit /etc/nixos/modules/packages.nix and rebuild"
    echo "  - Service not running: Check 'systemctl status <service>'"
    echo "  - Config missing: Check home-manager linked files correctly"
    echo "  - Rebuild system: sudo nixos-rebuild switch --flake /etc/nixos#vivobook"
    exit 1
fi
