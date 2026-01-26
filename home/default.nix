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
  # Hyprland Configuration
  # ═══════════════════════════════════════════════════════════════════
  
  # Hyprland compositor config (your actual config from Arch)
  xdg.configFile."hypr/hyprland.conf".source = ./dotfiles/hypr/hyprland.conf;
  xdg.configFile."hypr/monitors.conf".source = ./dotfiles/hypr/monitors.conf;
  xdg.configFile."hypr/workspaces.conf".source = ./dotfiles/hypr/workspaces.conf;
  xdg.configFile."hypr/wallust-colors.conf".source = ./dotfiles/hypr/wallust-colors.conf;
  
  # Hyprlock (screen locker)
  xdg.configFile."hypr/hyprlock.conf".source = ./dotfiles/hypr/hyprlock.conf;
  
  # Hypridle (idle manager)
  xdg.configFile."hypr/hypridle.conf".source = ./dotfiles/hypr/hypridle.conf;
  
  # Hyprpaper (wallpaper daemon)
  xdg.configFile."hypr/hyprpaper.conf".source = ./dotfiles/hypr/hyprpaper.conf;

  # Thunar performance config (sourced by hyprland.conf)
  xdg.configFile."hypr/thunar-performance.conf".source = ./dotfiles/hypr/thunar-performance.conf;

  # Hypr scripts (wallpaper, screenshot, startup, etc.)
  xdg.configFile."hypr/scripts" = {
    source = ./dotfiles/hypr/scripts;
    recursive = true;
  };
  
  # Hypr assets (images for hyprlock, etc.)
  xdg.configFile."hypr/assets" = {
    source = ./dotfiles/hypr/assets;
    recursive = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # Waybar Configuration
  # ═══════════════════════════════════════════════════════════════════
  
  programs.waybar.enable = true;
  
  # Bundled Waybar config (your Hyprland-compatible setup)
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
  xdg.configFile."kitty/kitty.conf".source = ./dotfiles/kitty/kitty.conf;
  
  # Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "docker" "kubectl" "command-not-found" "z" ];
      theme = "";  # Using Starship instead
    };
    
    # Shell aliases
    shellAliases = {
      # File listing
      ls = "ls --color=auto";
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
      
      # Better defaults
      cat = "bat";
      find = "fd";
      grep = "rg";
      top = "btop";
      
      # NixOS system management
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#mnemosyne";
      update = "sudo nix flake update /etc/nixos && sudo nixos-rebuild switch --flake /etc/nixos#mnemosyne";
      clean = "sudo nix-collect-garbage -d";
      search = "nix search nixpkgs";
      
      # File operations (safe)
      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -i";
      mkdir = "mkdir -pv";
      
      # Directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "~" = "cd ~";
      
      # Git shortcuts
      g = "git";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gs = "git status";
      gd = "git diff";
      gco = "git checkout";
      gb = "git branch";
      glog = "git log --oneline --graph";
      
      # Media
      music = "ncspot";
      play = "playerctl play-pause";
      next = "playerctl next";
      prev = "playerctl previous";
      stop = "playerctl stop";
    };
    
    initExtra = ''
      # Source local zshrc if it exists (for machine-specific config)
      if [ -f ~/.zshrc.local ]; then
        source ~/.zshrc.local
      fi
      
      # Add local bin to path
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };
  
  # Starship prompt
  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ./dotfiles/starship.toml;

  # ═══════════════════════════════════════════════════════════════════
  # Mako Notification Daemon
  # ═══════════════════════════════════════════════════════════════════
  
  services.mako.enable = true;
  xdg.configFile."mako/config".source = ./dotfiles/mako/config;

  # ═══════════════════════════════════════════════════════════════════
  # Fuzzel Launcher
  # ═══════════════════════════════════════════════════════════════════
  
  programs.fuzzel.enable = true;
  xdg.configFile."fuzzel/fuzzel.ini".source = ./dotfiles/fuzzel/fuzzel.ini;

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

  # ═══════════════════════════════════════════════════════════════════
  # Tmux
  # ═══════════════════════════════════════════════════════════════════
  
  programs.tmux.enable = true;

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
    
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };
  
  # Qt theming
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # Browser Configuration (Wayland-native)
  # ═══════════════════════════════════════════════════════════════════
  
  xdg.configFile."brave-flags.conf".text = ''
    --enable-features=UseOzonePlatform
    --ozone-platform=wayland
    --enable-wayland-ime
  '';
  
  xdg.configFile."chromium-flags.conf".text = ''
    --enable-features=UseOzonePlatform
    --ozone-platform=wayland
    --enable-wayland-ime
  '';
  
  xdg.configFile."electron-flags.conf".text = ''
    --enable-features=UseOzonePlatform
    --ozone-platform=wayland
    --enable-wayland-ime
  '';

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
  # Wallpapers
  # ═══════════════════════════════════════════════════════════════════
  
  home.file."Pictures/Wallpapers" = {
    source = ./dotfiles/wallpapers;
    recursive = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # Local bin scripts (wallpaper, etc.)
  # ═══════════════════════════════════════════════════════════════════
  
  home.file.".local/bin/quick-wallpaper" = {
    source = ./dotfiles/bin/quick-wallpaper;
    executable = true;
  };
  
  home.file.".local/bin/wallpaper-manager" = {
    source = ./dotfiles/bin/wallpaper-manager;
    executable = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # GNOME Keyring - Required for VSCode auth and secret storage
  # ═══════════════════════════════════════════════════════════════════
  
  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" "ssh" ];
  };

  # ═══════════════════════════════════════════════════════════════════
  # Default Applications (for xdg-open - VSCode browser auth)
  # ═══════════════════════════════════════════════════════════════════
  
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };
}
