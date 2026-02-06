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
  
  # Graphics (Intel integrated)
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver    # VA-API for newer Intel (Broadwell+)
      intel-vaapi-driver    # VA-API for older Intel
      vpl-gpu-rt            # Intel Quick Sync Video
      libvdpau-va-gl        # VDPAU backend for VA-API
    ];
  };
  
  # Power management (for UPower battery info)
  services.upower.enable = true;
}
