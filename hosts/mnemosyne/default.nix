# Host: Mnemosyne
# ASUS Vivobook S15 - primary laptop
#
# This is the entry point for this specific machine.
# It imports hardware config + profiles that define what this machine does.

{ config, pkgs, lib, inputs, username, ... }:

{
  imports = [
    # Hardware (machine-specific)
    ./hardware.nix
    
    # Profiles (what role does this machine serve?)
    ../../profiles/desktop.nix
    ../../profiles/development.nix
    
    # Stylix theming (must come early)
    inputs.stylix.nixosModules.stylix
    ../../modules/stylix.nix
  ];

  # ───────────────────────────────────────────────────────────
  # Machine Identity
  # ───────────────────────────────────────────────────────────
  networking.hostName = "mnemosyne";
  
  # ───────────────────────────────────────────────────────────
  # Machine-Specific Overrides
  # Anything unique to THIS machine goes here
  # ───────────────────────────────────────────────────────────
  
  # Example: this machine's specific hosts file entries
  # networking.hosts = {
  #   "192.168.1.100" = [ "homeserver" "immich.local" ];
  # };
}
