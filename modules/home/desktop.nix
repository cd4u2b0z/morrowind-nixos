# Home Module: Desktop
#
# Hyprland user config, waybar, mako, fuzzel, idle/lock.
#
# Extracted from: home/default.nix

{ config, lib, pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════════════
  # Hyprland Configuration
  # ═══════════════════════════════════════════════════════════════════
  
  # Hyprland compositor config (your actual config from Arch)
  xdg.configFile."hypr/hyprland.conf".source = ../../home/dotfiles/hypr/hyprland.conf;
  xdg.configFile."hypr/monitors.conf".source = ../../home/dotfiles/hypr/monitors.conf;
  xdg.configFile."hypr/workspaces.conf".source = ../../home/dotfiles/hypr/workspaces.conf;
  
  # Hyprlock (screen locker)
  xdg.configFile."hypr/hyprlock.conf" = {
    source = ../../home/dotfiles/hypr/hyprlock.conf;
    force = true;
  };
  
  # Hypridle (idle manager)
  xdg.configFile."hypr/hypridle.conf".source = ../../home/dotfiles/hypr/hypridle.conf;
  
  # Hyprpaper (wallpaper daemon)
  xdg.configFile."hypr/hyprpaper.conf".source = ../../home/dotfiles/hypr/hyprpaper.conf;

  # Thunar performance config (sourced by hyprland.conf)
  xdg.configFile."hypr/thunar-performance.conf".source = ../../home/dotfiles/hypr/thunar-performance.conf;

  # Hypr scripts (wallpaper, screenshot, startup, etc.)
  xdg.configFile."hypr/scripts" = {
    source = ../../home/dotfiles/hypr/scripts;
    recursive = true;
  };
  
  # Hypr assets (images for hyprlock, etc.)
  xdg.configFile."hypr/assets" = {
    source = ../../home/dotfiles/hypr/assets;
    recursive = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # Waybar Configuration
  # ═══════════════════════════════════════════════════════════════════
  
  programs.waybar = {
    enable = true;
    # Load config from JSON, we provide custom style.css with Nord colors
    settings = [ (builtins.fromJSON (builtins.readFile ../../home/dotfiles/waybar/config)) ];
    # Don't let Stylix generate style - we use our custom one
    style = builtins.readFile ../../home/dotfiles/waybar/style.css;
  };
  
  # Waybar Nord colors (our custom color file)
  xdg.configFile."waybar/nord-colors.css".source = ../../home/dotfiles/waybar/nord-colors.css;
  
  # Waybar scripts (custom modules like weather, system-stats)
  xdg.configFile."waybar/scripts" = {
    source = ../../home/dotfiles/waybar/scripts;
    recursive = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # Mako Notification Daemon
  # ═══════════════════════════════════════════════════════════════════
  
  services.mako = {
    enable = true;
    # Stylix handles colors, we set layout/behavior
    settings = {
      sort = "-time";
      layer = "overlay";
      width = 350;
      height = 120;
      border-size = 2;
      border-radius = 12;
      margin = "12";
      padding = "16";
      max-history = 50;
      max-visible = 5;
      anchor = "top-right";
      default-timeout = 4000;
      icons = 1;
      max-icon-size = 64;
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # Fuzzel Launcher
  # ═══════════════════════════════════════════════════════════════════
  
  programs.fuzzel = {
    enable = true;
    # Stylix handles colors, we set layout/behavior
    settings = {
      main = {
        dpi-aware = "auto";
        icon-theme = "Papirus-Dark";
        terminal = "kitty";
        layer = "overlay";
        prompt = "\" \"";
        width = 45;
        horizontal-pad = 20;
        vertical-pad = 12;
        inner-pad = 8;
        line-height = 22;
        letter-spacing = 0;
      };
      border = {
        width = 2;
        radius = 12;
      };
      dmenu = {
        exit-immediately-if-empty = "no";
      };
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # Idle & Lock Services
  # ═══════════════════════════════════════════════════════════════════
  
  services.hypridle = {
    enable = true;
    # Config in hypr/hypridle.conf
  };
}
