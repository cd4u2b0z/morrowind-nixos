# Stylix - System-wide Theming
# https://github.com/danth/stylix
#
# Change theme by editing base16Scheme below and running:
#   sudo nixos-rebuild switch --flake .#mnemosyne
#
# Popular themes:
#   nord, gruvbox-dark-hard, gruvbox-dark-medium, catppuccin-mocha,
#   catppuccin-macchiato, dracula, tokyo-night-dark, rose-pine,
#   everforest, solarized-dark, one-dark

{ pkgs, ... }:

{
  stylix = {
    enable = true;
    
    # ═══════════════════════════════════════════════════════════════════
    # 🎨 THEME - Change this to switch your entire system theme!
    # ═══════════════════════════════════════════════════════════════════
    
    # Use a base16 scheme (see: https://github.com/tinted-theming/schemes)
    base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
    
    # Alternative themes (uncomment one to use):
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
        package = pkgs.noto-fonts-emoji;
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
      package = pkgs.nordzy-cursor-theme;
      name = "Nordzy-cursors-white";
      size = 24;
    };
    
    # ═══════════════════════════════════════════════════════════════════
    # ⚙️ TARGET CONFIGURATION
    # ═══════════════════════════════════════════════════════════════════
    
    # Polarity: "dark" or "light"
    polarity = "dark";
    
    # Enable Stylix theming for these apps
    targets = {
      # Desktop
      gtk.enable = true;
      hyprland.enable = true;
      
      # Terminal
      kitty.enable = true;
      
      # Notifications
      mako.enable = true;
      
      # Launcher  
      fuzzel.enable = true;
      
      # Bar
      waybar.enable = true;
      
      # Console (TTY)
      console.enable = true;
      
      # Neovim (via base16 plugin)
      neovim.enable = true;
      
      # Tmux
      tmux.enable = true;
    };
  };
}
