# Home Module: Media
#
# Cava, fastfetch, mpv and media-related configs.
#
# Extracted from: home/default.nix

{ config, lib, pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════════════
  # Cava Audio Visualizer
  # ═══════════════════════════════════════════════════════════════════
  
  xdg.configFile."cava/config".source = ../../home/dotfiles/cava/config;

  # ═══════════════════════════════════════════════════════════════════
  # Fastfetch (System Info)
  # ═══════════════════════════════════════════════════════════════════
  
  xdg.configFile."fastfetch/config.jsonc".source = ../../home/dotfiles/fastfetch/config.jsonc;
  xdg.configFile."fastfetch/logo.png".source = ../../home/dotfiles/fastfetch/logo.png;

  # ═══════════════════════════════════════════════════════════════════
  # MPV Video Player
  # ═══════════════════════════════════════════════════════════════════
  
  programs.mpv = {
    enable = true;
    config = {
      # Hardware acceleration
      hwdec = "auto-safe";
      vo = "gpu";
      
      # Quality
      profile = "gpu-hq";
    };
  };
}
