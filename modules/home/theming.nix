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
  
  gtk = let
    # Build Papirus-Dark with orange/amber folders (Dwemer gold)
    # papirus-folders can't run at activation time (Nix store is read-only),
    # so we patch the icon theme at build time instead.
    papirus-dark-orange = pkgs.runCommandLocal "papirus-dark-orange" {
      nativeBuildInputs = [ pkgs.papirus-folders pkgs.papirus-icon-theme pkgs.getent ];
    } ''
      mkdir -p $out/share/icons
      cp -r --no-preserve=mode ${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark $out/share/icons/Papirus-Dark

      export HOME=$(mktemp -d)
      ${pkgs.papirus-folders}/bin/papirus-folders -C orange --theme Papirus-Dark -o $out/share/icons
    '';
  in {
    enable = true;
    
    # Papirus-Dark with Dwemer gold (orange) folders
    iconTheme = {
      name = "Papirus-Dark";
      package = papirus-dark-orange;
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
