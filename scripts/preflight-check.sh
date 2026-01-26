#!/usr/bin/env bash
# NixOS + Hyprland Pre-flight Check Script
# Run before nixos-rebuild to catch common issues

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
}

pass() { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; ((WARNINGS++)); }
error() { echo -e "  ${RED}✗${NC} $1"; ((ERRORS++)); }
info() { echo -e "  ${CYAN}ℹ${NC} $1"; }

# Determine config directory
if [[ -d "/etc/nixos" ]]; then
    CONFIG_DIR="/etc/nixos"
elif [[ -d "$(pwd)" && -f "$(pwd)/flake.nix" ]]; then
    CONFIG_DIR="$(pwd)"
else
    echo -e "${RED}Error: Cannot find NixOS config directory${NC}"
    exit 1
fi

echo -e "\n${GREEN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}     ${CYAN}NixOS + Hyprland Pre-flight Check${NC}                            ${GREEN}║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
info "Config directory: $CONFIG_DIR"

# ═══════════════════════════════════════════════════════════════════
header "Flake Structure"

FLAKE="$CONFIG_DIR/flake.nix"
if [[ -f "$FLAKE" ]]; then
    pass "flake.nix exists"
    
    if grep -q "nixpkgs" "$FLAKE"; then
        pass "nixpkgs input defined"
    else
        error "nixpkgs input not found"
    fi
    
    if grep -q "home-manager" "$FLAKE"; then
        pass "home-manager input defined"
    else
        warn "home-manager input not found"
    fi
else
    error "flake.nix not found"
fi

# Check flake.lock
if [[ -f "$CONFIG_DIR/flake.lock" ]]; then
    pass "flake.lock exists"
else
    warn "flake.lock not found - run 'nix flake update'"
fi

# ═══════════════════════════════════════════════════════════════════
header "Required NixOS Modules"

REQUIRED_MODULES=(
    "modules/hyprland.nix"
    "modules/packages.nix"
    "modules/services.nix"
    "modules/system.nix"
    "hardware-configuration.nix"
)

for module in "${REQUIRED_MODULES[@]}"; do
    if [[ -f "$CONFIG_DIR/$module" ]]; then
        pass "$module exists"
    else
        error "$module not found"
    fi
done

# ═══════════════════════════════════════════════════════════════════
header "Hardware Configuration"

HW_CONFIG="$CONFIG_DIR/hardware-configuration.nix"
if [[ -f "$HW_CONFIG" ]]; then
    if grep -q "REPLACE-WITH" "$HW_CONFIG"; then
        error "hardware-configuration.nix contains placeholder UUIDs!"
        info "Run: blkid to get your partition UUIDs"
    else
        pass "No placeholder UUIDs found"
    fi
    
    if grep -q 'fileSystems."/"' "$HW_CONFIG"; then
        pass "Root filesystem defined"
    else
        error "Root filesystem not defined"
    fi
    
    if grep -q 'fileSystems."/boot"' "$HW_CONFIG"; then
        pass "Boot filesystem defined"
    else
        error "Boot filesystem not defined"
    fi
fi

# ═══════════════════════════════════════════════════════════════════
header "Hyprland Configuration"

HYPR_MODULE="$CONFIG_DIR/modules/hyprland.nix"
if [[ -f "$HYPR_MODULE" ]]; then
    if grep -q "programs.hyprland.enable = true" "$HYPR_MODULE"; then
        pass "Hyprland enabled in NixOS module"
    else
        warn "programs.hyprland.enable not found"
    fi
    
    if grep -q "services.displayManager.sddm" "$HYPR_MODULE"; then
        pass "Display manager (SDDM) configured"
    else
        warn "No display manager configured"
    fi
fi

# Check Hyprland user config
HYPR_CONFIG="$CONFIG_DIR/home/dotfiles/hypr/hyprland.conf"
if [[ -f "$HYPR_CONFIG" ]]; then
    pass "Hyprland user config exists"
    
    if grep -q "exec-once" "$HYPR_CONFIG"; then
        pass "Startup programs configured"
    else
        warn "No exec-once startup programs found"
    fi
    
    if grep -q "monitor" "$HYPR_CONFIG" || [[ -f "$CONFIG_DIR/home/dotfiles/hypr/monitors.conf" ]]; then
        pass "Monitor configuration found"
    else
        warn "No monitor configuration found"
    fi
else
    error "Hyprland user config not found"
fi

# ═══════════════════════════════════════════════════════════════════
header "Waybar Configuration"

WAYBAR_CONFIG="$CONFIG_DIR/home/dotfiles/waybar/config"
if [[ -f "$WAYBAR_CONFIG" ]]; then
    pass "Waybar config exists"
    
    if grep -q "hyprland/workspaces" "$WAYBAR_CONFIG"; then
        pass "Using hyprland/workspaces module"
    elif grep -q "niri/workspaces" "$WAYBAR_CONFIG"; then
        error "Still using niri/workspaces - should be hyprland/workspaces"
    else
        warn "No workspace module found in waybar config"
    fi
else
    error "Waybar config not found"
fi

# ═══════════════════════════════════════════════════════════════════
header "Home Manager"

HM_CONFIG="$CONFIG_DIR/home/default.nix"
if [[ -f "$HM_CONFIG" ]]; then
    pass "home/default.nix exists"
    
    if grep -q "xdg.configFile" "$HM_CONFIG"; then
        pass "XDG config files configured"
    else
        warn "No xdg.configFile entries found"
    fi
    
    if grep -q "programs.zsh" "$HM_CONFIG"; then
        pass "Zsh configured"
    else
        warn "Zsh not configured in home-manager"
    fi
else
    error "home/default.nix not found"
fi

# ═══════════════════════════════════════════════════════════════════
header "Dotfiles"

REQUIRED_DOTFILES=(
    "home/dotfiles/hypr/hyprland.conf"
    "home/dotfiles/hypr/hyprlock.conf"
    "home/dotfiles/waybar/config"
    "home/dotfiles/waybar/style.css"
    "home/dotfiles/kitty/kitty.conf"
)

for dotfile in "${REQUIRED_DOTFILES[@]}"; do
    if [[ -f "$CONFIG_DIR/$dotfile" ]]; then
        pass "$dotfile"
    else
        warn "$dotfile not found"
    fi
done

# ═══════════════════════════════════════════════════════════════════
header "Summary"

echo ""
if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    echo -e "  ${GREEN}✓ All checks passed! Ready to build.${NC}"
    echo -e "  Run: ${CYAN}sudo nixos-rebuild switch --flake $CONFIG_DIR#mnemosyne${NC}"
elif [[ $ERRORS -eq 0 ]]; then
    echo -e "  ${YELLOW}⚠ $WARNINGS warning(s) found. Review above.${NC}"
    echo -e "  You can still try: ${CYAN}sudo nixos-rebuild switch --flake $CONFIG_DIR#mnemosyne${NC}"
else
    echo -e "  ${RED}✗ $ERRORS error(s) and $WARNINGS warning(s) found.${NC}"
    echo -e "  Please fix the errors before building."
fi
echo ""

exit $ERRORS
