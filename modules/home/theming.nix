# Home Module: Theming
#
# GTK, wallpapers, wallust, local scripts.
#
# Extracted from: home/default.nix

{ config, lib, pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════════════
  # Stylix profile targets
  # ═══════════════════════════════════════════════════════════════════
  
  stylix.targets.librewolf.profileNames = [ "default" ];

  # ═══════════════════════════════════════════════════════════════════
  # GTK Theming (Stylix handles theme/cursor/fonts, we add icons)
  # ═══════════════════════════════════════════════════════════════════
  
  gtk = {
    enable = true;
    
    # Icons not handled by Stylix
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  # ═══════════════════════════════════════════════════════════════════
  # Wallust (dynamic theming)
  # ═══════════════════════════════════════════════════════════════════
  
  xdg.configFile."wallust".source = ../../home/dotfiles/wallust;

  # ═══════════════════════════════════════════════════════════════════
  # Wallpapers
  # ═══════════════════════════════════════════════════════════════════
  
  home.file."Pictures/Wallpapers" = {
    source = ../../home/dotfiles/wallpapers;
    recursive = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # Local bin scripts (wallpaper, etc.)
  # ═══════════════════════════════════════════════════════════════════
  
  home.file.".local/bin/quick-wallpaper" = {
    source = ../../home/dotfiles/bin/quick-wallpaper;
    executable = true;
  };
  
  home.file.".local/bin/wallpaper-manager" = {
    source = ../../home/dotfiles/bin/wallpaper-manager;
    executable = true;
  };
}
