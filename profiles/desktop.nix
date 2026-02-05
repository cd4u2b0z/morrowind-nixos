# Profile: Desktop
#
# Full Hyprland desktop experience.
# Imports all modules needed for a graphical workstation.

{ config, pkgs, lib, ... }:

{
  imports = [
    ../modules/nixos/core.nix
    ../modules/nixos/networking.nix
    ../modules/nixos/desktop.nix
    ../modules/nixos/audio.nix
    ../modules/nixos/services.nix
    ../modules/nixos/packages.nix
    ../modules/nixos/immich.nix
  ];

  # ═══════════════════════════════════════════════════════════════════
  # Desktop Profile Additions
  # ═══════════════════════════════════════════════════════════════════
  
  # Graphics
  hardware.graphics.enable = true;
}
