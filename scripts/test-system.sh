#!/usr/bin/env bash
# NixOS + Hyprland System Validation Script
# Run after installation to verify everything works

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
}

pass() { echo -e "  ${GREEN}✓${NC} $1"; ((PASS++)); }
fail() { echo -e "  ${RED}✗${NC} $1"; ((FAIL++)); }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; ((WARN++)); }
info() { echo -e "  ${CYAN}ℹ${NC} $1"; }

test_cmd() {
    if command -v "$1" &>/dev/null; then
        pass "$1 available"
    else
        fail "$1 not found"
    fi
}

test_file() {
    if [[ -f "$1" ]]; then
        pass "$(basename "$1") exists"
    else
        fail "$(basename "$1") not found"
    fi
}

test_service() {
    if systemctl is-active --quiet "$1" 2>/dev/null; then
        pass "$1 running"
    else
        warn "$1 not running"
    fi
}

test_user_service() {
    if systemctl --user is-active --quiet "$1" 2>/dev/null; then
        pass "$1 (user) running"
    else
        warn "$1 (user) not running"
    fi
}

echo -e "\n${GREEN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}     ${CYAN}NixOS + Hyprland System Validation${NC}                           ${GREEN}║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════╝${NC}"

# ═══════════════════════════════════════════════════════════════════
header "Core System"

test_cmd nixos-rebuild
test_cmd nix
info "NixOS Version: $(nixos-version 2>/dev/null || echo 'unknown')"
info "Kernel: $(uname -r)"

# ═══════════════════════════════════════════════════════════════════
header "Hyprland & Wayland"

test_cmd Hyprland
test_cmd hyprctl
test_cmd hyprlock
test_cmd hypridle

if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    pass "Running under Wayland"
    info "Display: $WAYLAND_DISPLAY"
else
    warn "Not running under Wayland"
    info "Run this script from within Hyprland for full validation"
fi

if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    pass "Running under Hyprland"
else
    warn "Not running under Hyprland"
fi

# ═══════════════════════════════════════════════════════════════════
header "Configuration Files"

test_file ~/.config/hypr/hyprland.conf
test_file ~/.config/hypr/hyprlock.conf
test_file ~/.config/hypr/hypridle.conf
test_file ~/.config/waybar/config
test_file ~/.config/waybar/style.css
test_file ~/.config/kitty/kitty.conf

# ═══════════════════════════════════════════════════════════════════
header "Shell & Terminal"

test_cmd zsh
test_cmd kitty
test_cmd starship

if [[ "$SHELL" == *"zsh"* ]]; then
    pass "Default shell is zsh"
else
    warn "Default shell is not zsh: $SHELL"
fi

# ═══════════════════════════════════════════════════════════════════
header "Desktop Components"

test_cmd waybar
test_cmd fuzzel
test_cmd mako
test_cmd wl-copy
test_cmd wl-paste
test_cmd grim
test_cmd slurp

# ═══════════════════════════════════════════════════════════════════
header "Applications"

test_cmd brave
test_cmd firefox
test_cmd thunar
test_cmd code  # VSCode

# ═══════════════════════════════════════════════════════════════════
header "Audio (PipeWire)"

test_cmd pipewire
test_cmd wpctl
test_cmd pavucontrol
test_service pipewire
test_user_service pipewire

# Check audio output
if wpctl status &>/dev/null; then
    pass "PipeWire responding"
else
    warn "PipeWire not responding"
fi

# ═══════════════════════════════════════════════════════════════════
header "System Services"

test_service NetworkManager
test_service bluetooth
test_service sddm

# ═══════════════════════════════════════════════════════════════════
header "Graphics"

if command -v glxinfo &>/dev/null; then
    RENDERER=$(glxinfo 2>/dev/null | grep "OpenGL renderer" | cut -d: -f2 | xargs)
    if [[ -n "$RENDERER" ]]; then
        pass "OpenGL working: $RENDERER"
    else
        warn "Cannot determine OpenGL renderer"
    fi
else
    info "glxinfo not available (install mesa-demos to test)"
fi

# VAAPI
if command -v vainfo &>/dev/null; then
    if vainfo &>/dev/null; then
        pass "VAAPI hardware acceleration available"
    else
        warn "VAAPI not working"
    fi
else
    info "vainfo not available (install libva-utils to test)"
fi

# ═══════════════════════════════════════════════════════════════════
header "Fonts"

if fc-list | grep -qi "nerd"; then
    pass "Nerd Fonts installed"
else
    warn "Nerd Fonts may not be installed"
fi

if fc-list | grep -qi "noto"; then
    pass "Noto Fonts installed"
else
    warn "Noto Fonts may not be installed"
fi

# ═══════════════════════════════════════════════════════════════════
header "Network"

if nmcli general status &>/dev/null; then
    pass "NetworkManager working"
    if nmcli -t -f TYPE,STATE dev | grep -q "wifi:connected"; then
        pass "WiFi connected"
    else
        info "WiFi not connected (may be using ethernet)"
    fi
else
    warn "NetworkManager not responding"
fi

# ═══════════════════════════════════════════════════════════════════
header "Summary"

TOTAL=$((PASS + FAIL + WARN))
echo ""
echo -e "  ${GREEN}Passed:${NC}   $PASS"
echo -e "  ${RED}Failed:${NC}   $FAIL"
echo -e "  ${YELLOW}Warnings:${NC} $WARN"
echo ""

if [[ $FAIL -eq 0 ]]; then
    echo -e "  ${GREEN}✓ System validation complete!${NC}"
else
    echo -e "  ${YELLOW}⚠ Some issues found. Review the output above.${NC}"
fi
echo ""

exit $FAIL
