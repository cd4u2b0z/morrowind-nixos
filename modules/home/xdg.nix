# Home Module: XDG & Services
#
# XDG directories, GNOME keyring, dconf.
#
# Extracted from: home/default.nix

{ config, lib, pkgs, username, ... }:

{
  # ═══════════════════════════════════════════════════════════════════
  # Home Manager Basics
  # ═══════════════════════════════════════════════════════════════════
  
  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.05";
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Enable dconf (required for gsettings to work)
  dconf.enable = true;

  # ═══════════════════════════════════════════════════════════════════
  # XDG User Directories
  # ═══════════════════════════════════════════════════════════════════
  
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "${config.home.homeDirectory}/Desktop";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    videos = "${config.home.homeDirectory}/Videos";
    templates = "${config.home.homeDirectory}/Templates";
    publicShare = "${config.home.homeDirectory}/Public";
  };

  # Create Screenshots directory for grim/screenshot bindings
  home.file."Pictures/Screenshots/.keep".text = "";

  # ═══════════════════════════════════════════════════════════════════
  # GNOME Keyring - Required for VSCode auth and secret storage
  # ═══════════════════════════════════════════════════════════════════
  
  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" "ssh" ];
  };
}
