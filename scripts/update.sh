#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# Update Script
# Update flake inputs and rebuild with safety checks
# ─────────────────────────────────────────────────────────────

set -euo pipefail

FLAKE_DIR="${FLAKE_DIR:-$(dirname "$(dirname "$(realpath "$0")")")}"
HOST="${HOST:-mnemosyne}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
step() { echo -e "${BLUE}[STEP]${NC} $1"; }

cd "$FLAKE_DIR"

# ─────────────────────────────────────────────────────────────
# Show what will change
# ─────────────────────────────────────────────────────────────
step "Checking for updates..."
nix flake update --dry-run 2>&1 | head -20 || true

echo ""
read -p "Proceed with update? [y/N] " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  info "Aborted."
  exit 0
fi

# ─────────────────────────────────────────────────────────────
# Backup lock file
# ─────────────────────────────────────────────────────────────
step "Backing up flake.lock..."
cp flake.lock "flake.lock.backup-$(date +%Y%m%d-%H%M%S)"

# ─────────────────────────────────────────────────────────────
# Update
# ─────────────────────────────────────────────────────────────
step "Updating flake inputs..."
nix flake update

# ─────────────────────────────────────────────────────────────
# Test build
# ─────────────────────────────────────────────────────────────
step "Testing build..."
if sudo nixos-rebuild test --flake ".#${HOST}"; then
  info "Test successful!"
  
  echo ""
  read -p "Switch to new configuration? [y/N] " -n 1 -r
  echo ""
  
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    step "Switching..."
    sudo nixos-rebuild switch --flake ".#${HOST}"
    info "Update complete!"
    
    # Commit the update
    if git rev-parse --is-inside-work-tree &>/dev/null; then
      step "Committing flake.lock..."
      git add flake.lock
      git commit -m "chore: update flake inputs $(date +%Y-%m-%d)" || true
    fi
  fi
else
  warn "Test failed! Restoring backup..."
  mv "flake.lock.backup-"* flake.lock 2>/dev/null || true
  exit 1
fi
