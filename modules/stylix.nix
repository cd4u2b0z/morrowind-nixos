# Stylix - System-wide Theming
# https://github.com/danth/stylix
#
# Change theme by editing base16Scheme below and running:
#   sudo nixos-rebuild switch --flake .#mnemosyne
#
# Current Theme: TES III: Morrowind
#   Volcanic ashlands, Dwemer gold, Telvanni arcana, parchment scrolls.
#
# Alternative themes (from base16-schemes):
#   nord, gruvbox-dark-hard, catppuccin-mocha, dracula, tokyo-night-dark,
#   rose-pine, everforest, solarized-dark, one-dark

{ pkgs, ... }:

{
  stylix = {
    enable = true;
    
    # ═══════════════════════════════════════════════════════════════════
    # 🎨 THEME — TES III: Morrowind
    # Ashlands, Dwemer gold, Telvanni teal, Daedric crimson
    # ═══════════════════════════════════════════════════════════════════
    
    # Custom Morrowind base16 scheme (lives in repo)
    base16Scheme = ../themes/morrowind.yaml;
    
    # Alternative built-in themes (uncomment to switch):
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
    
    # ═══════════════════════════════════════════════════════════════════
    # 🖼️ WALLPAPER
    # ═══════════════════════════════════════════════════════════════════
    
    # Set a wallpaper (Stylix will also extract accent colors if no scheme set)
    image = ../home/dotfiles/wallpapers/blue_woods.png;
    
    # ═══════════════════════════════════════════════════════════════════
    # 🔤 FONTS
    # ═══════════════════════════════════════════════════════════════════
    
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
      
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      
      sizes = {
        applications = 11;
        desktop = 11;
        popups = 11;
        terminal = 12;
      };
    };
    
    # ═══════════════════════════════════════════════════════════════════
    # 🖱️ CURSOR
    # ═══════════════════════════════════════════════════════════════════
    
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
    
    # ═══════════════════════════════════════════════════════════════════
    # ⚙️ TARGET CONFIGURATION
    # ═══════════════════════════════════════════════════════════════════
    
    # Polarity: "dark" or "light"
    polarity = "dark";
    
    # Stylix auto-enables theming for installed apps
    # No need to manually specify targets
  };
}
