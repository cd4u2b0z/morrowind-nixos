#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# Rebuild Script
# Safe NixOS rebuild with test-first approach
# ─────────────────────────────────────────────────────────────

set -euo pipefail

FLAKE_DIR="${FLAKE_DIR:-$(dirname "$(dirname "$(realpath "$0")")")}"
HOST="${HOST:-mnemosyne}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ─────────────────────────────────────────────────────────────
# Parse arguments
# ─────────────────────────────────────────────────────────────
ACTION="${1:-switch}"

case "$ACTION" in
  test|switch|boot|build)
    ;;
  *)
    echo "Usage: $0 [test|switch|boot|build]"
    echo "  test   - Build and activate, but don't add to bootloader"
    echo "  switch - Build, activate, and add to bootloader (default)"
    echo "  boot   - Build and add to bootloader, activate on next boot"
    echo "  build  - Just build, don't activate"
    exit 1
    ;;
esac

# ─────────────────────────────────────────────────────────────
# Preflight checks
# ─────────────────────────────────────────────────────────────
info "Running preflight checks..."

cd "$FLAKE_DIR"

# Check flake evaluates
if ! nix flake check --no-build 2>/dev/null; then
  warn "Flake check found issues (continuing anyway)"
fi

# ─────────────────────────────────────────────────────────────
# Rebuild
# ─────────────────────────────────────────────────────────────
if [[ "$ACTION" == "switch" ]]; then
  info "Testing configuration first..."
  if sudo nixos-rebuild test --flake ".#${HOST}"; then
    info "Test successful! Switching..."
    sudo nixos-rebuild switch --flake ".#${HOST}"
    info "Rebuild complete!"
  else
    error "Test failed! Not switching."
    exit 1
  fi
else
  info "Running: nixos-rebuild $ACTION --flake .#${HOST}"
  sudo nixos-rebuild "$ACTION" --flake ".#${HOST}"
  info "Done!"
fi

# ─────────────────────────────────────────────────────────────
# Post-rebuild
# ─────────────────────────────────────────────────────────────
if [[ "$ACTION" == "switch" ]]; then
  info "Current generation:"
  sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -5
fi
