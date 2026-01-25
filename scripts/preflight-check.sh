#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
# NixOS Pre-Flight Configuration Check
# Run this BEFORE nixos-install to catch errors early
# ═══════════════════════════════════════════════════════════════════════════

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
    ((ERRORS++))
}

warn() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
    ((WARNINGS++))
}

pass() {
    echo -e "${GREEN}✅ $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

header() {
    echo ""
    echo -e "${BLUE}━━━ $1 ━━━${NC}"
}

# ═══════════════════════════════════════════════════════════════════════════

echo ""
echo "═══════════════════════════════════════════════════════════════════════════"
echo "  NixOS Pre-Flight Configuration Check"
echo "═══════════════════════════════════════════════════════════════════════════"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"

info "Checking configuration in: $CONFIG_DIR"

# ═══════════════════════════════════════════════════════════════════════════
header "Required Files"
# ═══════════════════════════════════════════════════════════════════════════

REQUIRED_FILES=(
    "flake.nix"
    "hardware-configuration.nix"
    "modules/system.nix"
    "modules/niri.nix"
    "modules/packages.nix"
    "modules/services.nix"
    "home/default.nix"
    "home/dotfiles/niri/config.kdl"
    "home/dotfiles/waybar/config"
    "home/dotfiles/waybar/style.css"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$CONFIG_DIR/$file" ]]; then
        pass "$file exists"
    else
        error "$file is missing!"
    fi
done

# ═══════════════════════════════════════════════════════════════════════════
header "Nix Syntax Check"
# ═══════════════════════════════════════════════════════════════════════════

if command -v nix &>/dev/null; then
    # Check flake syntax
    if nix flake check "$CONFIG_DIR" --no-build 2>&1; then
        pass "Flake syntax is valid"
    else
        error "Flake has syntax errors"
        info "Run: nix flake check $CONFIG_DIR"
    fi
else
    warn "Nix not available - skipping syntax check"
    info "This is expected if running from NixOS installer"
fi

# ═══════════════════════════════════════════════════════════════════════════
header "Hardware Configuration"
# ═══════════════════════════════════════════════════════════════════════════

HW_CONFIG="$CONFIG_DIR/hardware-configuration.nix"

if [[ -f "$HW_CONFIG" ]]; then
    # Check for placeholder UUIDs
    if grep -q "REPLACE-WITH-YOUR" "$HW_CONFIG"; then
        error "hardware-configuration.nix contains placeholder UUIDs!"
        info "Run 'blkid' and replace the placeholder values"
        grep -n "REPLACE-WITH-YOUR" "$HW_CONFIG" | while read -r line; do
            echo "    Line $line"
        done
    else
        pass "No placeholder UUIDs found"
    fi
    
    # Check for root filesystem
    if grep -q 'fileSystems."/"' "$HW_CONFIG"; then
        pass "Root filesystem defined"
    else
        error "No root filesystem (/) defined"
    fi
    
    # Check for boot filesystem
    if grep -q 'fileSystems."/boot"' "$HW_CONFIG"; then
        pass "Boot filesystem defined"
    else
        error "No boot filesystem (/boot) defined"
    fi
    
    # Check boot loader
    if grep -q "boot.loader" "$HW_CONFIG" || grep -q "boot.loader" "$CONFIG_DIR/flake.nix" "$CONFIG_DIR/modules/"*.nix 2>/dev/null; then
        pass "Boot loader configuration found"
    else
        warn "Boot loader configuration not found in hardware config"
    fi
else
    error "hardware-configuration.nix not found!"
fi

# ═══════════════════════════════════════════════════════════════════════════
header "Flake Configuration"
# ═══════════════════════════════════════════════════════════════════════════

FLAKE="$CONFIG_DIR/flake.nix"

if [[ -f "$FLAKE" ]]; then
    # Check for username
    if grep -q 'username = "' "$FLAKE"; then
        USERNAME=$(grep 'username = "' "$FLAKE" | head -1 | sed 's/.*username = "\([^"]*\)".*/\1/')
        if [[ -n "$USERNAME" && "$USERNAME" != "YOUR_USERNAME" ]]; then
            pass "Username configured: $USERNAME"
        else
            error "Username not properly configured in flake.nix"
        fi
    else
        warn "Username variable not found in flake.nix"
    fi
    
    # Check for nixpkgs input
    if grep -q "nixpkgs" "$FLAKE"; then
        pass "nixpkgs input defined"
    else
        error "nixpkgs input not defined in flake"
    fi
    
    # Check for home-manager input
    if grep -q "home-manager" "$FLAKE"; then
        pass "home-manager input defined"
    else
        error "home-manager input not defined"
    fi
    
    # Check for niri input
    if grep -q "niri" "$FLAKE"; then
        pass "niri flake input defined"
    else
        warn "niri flake input not found (may be using nixpkgs version)"
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════
header "System Configuration"
# ═══════════════════════════════════════════════════════════════════════════

SYSTEM_NIX="$CONFIG_DIR/modules/system.nix"

if [[ -f "$SYSTEM_NIX" ]]; then
    # Check timezone
    if grep -q 'time.timeZone' "$SYSTEM_NIX"; then
        TIMEZONE=$(grep 'time.timeZone' "$SYSTEM_NIX" | sed 's/.*= "\([^"]*\)".*/\1/')
        if [[ -n "$TIMEZONE" ]]; then
            pass "Timezone configured: $TIMEZONE"
        fi
    else
        warn "Timezone not configured"
    fi
    
    # Check locale
    if grep -q 'i18n.defaultLocale' "$SYSTEM_NIX"; then
        pass "Locale configured"
    else
        warn "Locale not configured"
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════
header "Home Manager Configuration"
# ═══════════════════════════════════════════════════════════════════════════

HOME_NIX="$CONFIG_DIR/home/default.nix"

if [[ -f "$HOME_NIX" ]]; then
    # Check git config
    if grep -q 'programs.git' "$HOME_NIX"; then
        if grep -q 'userEmail = "your-email@example.com"' "$HOME_NIX" || \
           grep -q 'userEmail = "your@email.com"' "$HOME_NIX"; then
            warn "Git email is still placeholder - update home/default.nix"
        else
            pass "Git configuration looks customized"
        fi
    fi
    
    # Check dotfiles linking
    if grep -q 'xdg.configFile' "$HOME_NIX"; then
        pass "XDG config files are being linked"
    else
        warn "No XDG config file linking found"
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════
header "Niri Configuration"
# ═══════════════════════════════════════════════════════════════════════════

NIRI_CONFIG="$CONFIG_DIR/home/dotfiles/niri/config.kdl"

if [[ -f "$NIRI_CONFIG" ]]; then
    # Basic structure checks
    if grep -q "input {" "$NIRI_CONFIG"; then
        pass "Input block found"
    else
        warn "No input block in Niri config"
    fi
    
    if grep -q "binds {" "$NIRI_CONFIG"; then
        pass "Keybindings block found"
    else
        error "No keybindings in Niri config"
    fi
    
    if grep -q "spawn-at-startup" "$NIRI_CONFIG"; then
        pass "Startup programs configured"
    else
        warn "No startup programs in Niri config"
    fi
    
    # Check for waybar in startup
    if grep -q "waybar" "$NIRI_CONFIG"; then
        pass "Waybar in startup"
    else
        warn "Waybar not in Niri startup"
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════
header "Waybar Configuration"
# ═══════════════════════════════════════════════════════════════════════════

WAYBAR_CONFIG="$CONFIG_DIR/home/dotfiles/waybar/config"

if [[ -f "$WAYBAR_CONFIG" ]]; then
    # Check if valid JSON
    if command -v jq &>/dev/null; then
        if jq . "$WAYBAR_CONFIG" &>/dev/null; then
            pass "Waybar config is valid JSON"
        else
            error "Waybar config has JSON syntax errors"
        fi
    fi
    
    # Check for niri modules
    if grep -q "niri/workspaces" "$WAYBAR_CONFIG"; then
        pass "Using niri/workspaces module"
    elif grep -q "hyprland/workspaces" "$WAYBAR_CONFIG"; then
        error "Still using hyprland/workspaces - should be niri/workspaces"
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════
header "Scripts Executable"
# ═══════════════════════════════════════════════════════════════════════════

SCRIPT_DIRS=(
    "home/dotfiles/niri/scripts"
    "home/dotfiles/waybar/scripts"
    "scripts"
)

for dir in "${SCRIPT_DIRS[@]}"; do
    if [[ -d "$CONFIG_DIR/$dir" ]]; then
        NON_EXEC=$(find "$CONFIG_DIR/$dir" -name "*.sh" ! -executable 2>/dev/null | wc -l)
        if [[ $NON_EXEC -gt 0 ]]; then
            warn "$NON_EXEC scripts in $dir are not executable"
            info "Run: chmod +x $CONFIG_DIR/$dir/*.sh"
        else
            pass "All scripts in $dir are executable"
        fi
    fi
done

# ═══════════════════════════════════════════════════════════════════════════
header "Git Status"
# ═══════════════════════════════════════════════════════════════════════════

if [[ -d "$CONFIG_DIR/.git" ]]; then
    pass "Git repository initialized"
    
    # Check for uncommitted changes
    cd "$CONFIG_DIR"
    if git diff --quiet 2>/dev/null && git diff --cached --quiet 2>/dev/null; then
        pass "No uncommitted changes"
    else
        info "Uncommitted changes exist (OK for initial setup)"
    fi
else
    warn "Not a git repository - flakes require git"
    info "Run: cd $CONFIG_DIR && git init && git add -A"
fi

# ═══════════════════════════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════════════════════════

echo ""
echo "═══════════════════════════════════════════════════════════════════════════"
echo -e "  Results: ${RED}$ERRORS errors${NC}, ${YELLOW}$WARNINGS warnings${NC}"
echo "═══════════════════════════════════════════════════════════════════════════"

if [[ $ERRORS -eq 0 ]]; then
    echo -e "${GREEN}✅ Configuration looks good! Ready for installation.${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. cd $CONFIG_DIR"
    echo "  2. git init && git add -A  (if not already done)"
    echo "  3. sudo nixos-install --flake .#vivobook"
    exit 0
else
    echo -e "${RED}❌ Please fix the errors above before installing.${NC}"
    exit 1
fi
