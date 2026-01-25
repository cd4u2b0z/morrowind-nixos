# Home Manager Configuration
# User-specific configuration and dotfiles

{ config, lib, pkgs, username, ... }:

{
  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.05";
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # ═══════════════════════════════════════════════════════════════════
  # Niri Configuration
  # ═══════════════════════════════════════════════════════════════════
  
  # Niri compositor config (translated from your Hyprland config)
  xdg.configFile."niri/config.kdl".source = ./dotfiles/niri/config.kdl;
  
  # Niri scripts (wallpaper, screenshot, startup, etc.)
  xdg.configFile."niri/scripts" = {
    source = ./dotfiles/niri/scripts;
    recursive = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # Waybar Configuration
  # ═══════════════════════════════════════════════════════════════════
  
  programs.waybar.enable = true;
  
  # Bundled Waybar config (adapted for Niri)
  xdg.configFile."waybar/config".source = ./dotfiles/waybar/config;
  xdg.configFile."waybar/style.css".source = ./dotfiles/waybar/style.css;
  xdg.configFile."waybar/wallust-colors.css".source = ./dotfiles/waybar/wallust-colors.css;
  xdg.configFile."waybar/scripts" = {
    source = ./dotfiles/waybar/scripts;
    recursive = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # Terminal & Shell
  # ═══════════════════════════════════════════════════════════════════
  
  # Kitty terminal
  programs.kitty.enable = true;
  
  # Use bundled Kitty config
  xdg.configFile."kitty/kitty.conf".source = ./dotfiles/kitty/kitty.conf;
  
  # Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    oh-my-zsh = {
      enable = true;
      plugins = [ 
        "git" 
        "sudo" 
        "docker" 
        "kubectl" 
        "command-not-found"
        "z"
      ];
      theme = "";  # Using Starship instead
    };
    
    # Source your .zshrc from Chezmoi for custom config
    initExtra = ''
      # Source Chezmoi-managed zshrc if it exists
      if [ -f ~/.zshrc.local ]; then
        source ~/.zshrc.local
      fi
    '';
  };
  
  # Starship prompt
  programs.starship.enable = true;
  
  # Use bundled Starship config
  xdg.configFile."starship.toml".source = ./dotfiles/starship.toml;

  # ═══════════════════════════════════════════════════════════════════
  # Mako Notification Daemon
  # ═══════════════════════════════════════════════════════════════════
  
  services.mako.enable = true;
  
  # Use bundled Mako config
  xdg.configFile."mako/config".source = ./dotfiles/mako/config;

  # ═══════════════════════════════════════════════════════════════════
  # Fuzzel Launcher
  # ═══════════════════════════════════════════════════════════════════
  
  programs.fuzzel.enable = true;
  
  # Use bundled Fuzzel config
  xdg.configFile."fuzzel/fuzzel.ini".source = ./dotfiles/fuzzel/fuzzel.ini;

  # ═══════════════════════════════════════════════════════════════════
  # Swaylock (Screen locker)
  # ═══════════════════════════════════════════════════════════════════
  
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
  };
  
  # Use bundled Swaylock config
  xdg.configFile."swaylock/config".source = ./dotfiles/swaylock/config;

  # ═══════════════════════════════════════════════════════════════════
  # Swayidle (Idle manager)
  # ═══════════════════════════════════════════════════════════════════
  
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 300;  # 5 minutes
        command = "${pkgs.swaylock-effects}/bin/swaylock -f";
      }
      {
        timeout = 600;  # 10 minutes
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
  };

  # ═══════════════════════════════════════════════════════════════════
  # Git Configuration
  # ═══════════════════════════════════════════════════════════════════
  
  programs.git = {
    enable = true;
    userName = "craig";  # Change to your name
    userEmail = "your-email@example.com";  # Change to your email
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      core.editor = "nvim";
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # Neovim
  # ═══════════════════════════════════════════════════════════════════
  
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
  
  # Link Neovim config from Chezmoi
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink 
    "/home/${username}/.local/share/chezmoi/dot_config/nvim";

  # ═══════════════════════════════════════════════════════════════════
  # Tmux
  # ═══════════════════════════════════════════════════════════════════
  
  programs.tmux = {
    enable = true;
    # Link from Chezmoi or configure here
  };
  
  xdg.configFile."tmux".source = config.lib.file.mkOutOfStoreSymlink 
    "/home/${username}/.local/share/chezmoi/dot_config/tmux";

  # ═══════════════════════════════════════════════════════════════════
  # GTK Theming
  # ═══════════════════════════════════════════════════════════════════
  
  gtk = {
    enable = true;
    
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    
    cursorTheme = {
      name = "Nordzy-cursors";
      package = pkgs.nordzy-cursor-theme;
      size = 24;
    };
    
    font = {
      name = "Noto Sans";
      size = 11;
    };
    
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
  
  # Qt theming
  qt = {
    enable = true;
    platformTheme = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # Browser Configuration (Wayland-native)
  # ═══════════════════════════════════════════════════════════════════
  
  # LibreWolf - Firefox-based, uses MOZ_ENABLE_WAYLAND=1 from niri.nix
  # No extra config needed - inherits environment variables
  
  # Brave - Chromium-based, needs Ozone flags for native Wayland
  xdg.configFile."brave-flags.conf".text = ''
    --enable-features=UseOzonePlatform
    --ozone-platform=wayland
    --enable-wayland-ime
  '';
  
  # Chrome/Chromium flags (if you install them later)
  xdg.configFile."chromium-flags.conf".text = ''
    --enable-features=UseOzonePlatform
    --ozone-platform=wayland
    --enable-wayland-ime
  '';
  
  # Electron apps flags (VS Code, Discord, etc.)
  xdg.configFile."electron-flags.conf".text = ''
    --enable-features=UseOzonePlatform
    --ozone-platform=wayland
    --enable-wayland-ime
  '';

  # ═══════════════════════════════════════════════════════════════════
  # Additional Configuration Files from Chezmoi
  # ═══════════════════════════════════════════════════════════════════
  
  # Link other configs from Chezmoi
  xdg.configFile."btop".source = config.lib.file.mkOutOfStoreSymlink 
    "/home/${username}/.local/share/chezmoi/dot_config/btop";
  
  xdg.configFile."cava".source = config.lib.file.mkOutOfStoreSymlink 
    "/home/${username}/.local/share/chezmoi/dot_config/cava";
  
  xdg.configFile."fastfetch".source = config.lib.file.mkOutOfStoreSymlink 
    "/home/${username}/.local/share/chezmoi/dot_config/fastfetch";
  
  xdg.configFile."ncmpcpp".source = config.lib.file.mkOutOfStoreSymlink 
    "/home/${username}/.local/share/chezmoi/dot_config/ncmpcpp";
  
  xdg.configFile."ncspot".source = config.lib.file.mkOutOfStoreSymlink 
    "/home/${username}/.local/share/chezmoi/dot_config/ncspot";
  
  xdg.configFile."MangoHud".source = config.lib.file.mkOutOfStoreSymlink 
    "/home/${username}/.local/share/chezmoi/dot_config/MangoHud";
  
  xdg.configFile."Thunar".source = config.lib.file.mkOutOfStoreSymlink 
    "/home/${username}/.local/share/chezmoi/dot_config/private_Thunar";

  # ═══════════════════════════════════════════════════════════════════
  # User Scripts
  # ═══════════════════════════════════════════════════════════════════
  
  # Link local bin scripts
  home.file.".local/bin".source = config.lib.file.mkOutOfStoreSymlink 
    "/home/${username}/.local/share/chezmoi/private_dot_local/bin";

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

  # ═══════════════════════════════════════════════════════════════════
  # Wallpapers
  # ═══════════════════════════════════════════════════════════════════
  
  # Install wallpapers to ~/Pictures/Wallpapers
  home.file."Pictures/Wallpapers" = {
    source = ./dotfiles/wallpapers;
    recursive = true;
  };
}
