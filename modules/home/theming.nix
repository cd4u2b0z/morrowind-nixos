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

  # Prevent Stylix from overriding our custom Morrowind yazi theme
  stylix.targets.yazi.enable = false;

  # ═══════════════════════════════════════════════════════════════════
  # GTK Theming (Stylix handles theme/cursor/fonts, we add icons)
  # ═══════════════════════════════════════════════════════════════════
  
  gtk = {
    enable = true;
    
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  # Morrowind GTK3 CSS overrides (Thunar theming, etc.)
  # Must go through stylix.targets.gtk.extraCss — plain gtk.gtk3.extraCss is ignored by Stylix
  stylix.targets.gtk.extraCss = builtins.readFile ../../home/dotfiles/gtk-3.0/gtk.css;

  # ═══════════════════════════════════════════════════════════════════
  # Yazi file manager (Morrowind themed)
  # ═══════════════════════════════════════════════════════════════════

  xdg.configFile."yazi" = {
    source = ../../home/dotfiles/yazi;
    recursive = true;
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

  home.file.".local/bin/morrowind-greet" = {
    source = ../../home/dotfiles/bin/morrowind-greet;
    executable = true;
  };
}
