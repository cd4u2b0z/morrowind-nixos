# Home Manager Configuration
# User-specific configuration and dotfiles

{ config, lib, pkgs, username, ... }:

{
  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.05";
    
    # Cursor theme - set explicitly for all environments
    pointerCursor = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Enable dconf (required for gsettings to work)
  dconf.enable = true;

  # ═══════════════════════════════════════════════════════════════════
  # Hyprland Configuration
  # ═══════════════════════════════════════════════════════════════════
  
  # Hyprland compositor config (your actual config from Arch)
  xdg.configFile."hypr/hyprland.conf".source = ./dotfiles/hypr/hyprland.conf;
  xdg.configFile."hypr/monitors.conf".source = ./dotfiles/hypr/monitors.conf;
  xdg.configFile."hypr/workspaces.conf".source = ./dotfiles/hypr/workspaces.conf;
  # Hyprland colors now managed by Stylix
  
  # Hyprlock (screen locker)
  xdg.configFile."hypr/hyprlock.conf" = {
    source = ./dotfiles/hypr/hyprlock.conf;
    force = true;
  };
  
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
  # ════════════════════════════════════════════════════════════════════
  # Waybar Configuration
  # ════════════════════════════════════════════════════════════════════
  
  programs.waybar = {
    enable = true;
    # Load config from JSON, we provide custom style.css with Nord colors
    settings = [ (builtins.fromJSON (builtins.readFile ./dotfiles/waybar/config)) ];
    # Don't let Stylix generate style - we use our custom one
    style = builtins.readFile ./dotfiles/waybar/style.css;
  };
  
  # Waybar Nord colors (our custom color file)
  xdg.configFile."waybar/nord-colors.css".source = ./dotfiles/waybar/nord-colors.css;
  
  # Waybar scripts (custom modules like weather, system-stats)
  xdg.configFile."waybar/scripts" = {
    source = ./dotfiles/waybar/scripts;
    recursive = true;
  };

  # ════════════════════════════════════════════════════════════════════
  # Terminal & Shell
  # ════════════════════════════════════════════════════════════════════
  
  # Kitty terminal (Stylix handles colors, we add extra settings)
  programs.kitty = {
    enable = true;
    
    # Extra settings (non-color)
    settings = {
      
      # Cursor
      cursor_shape = "beam";
      cursor_beam_thickness = "1.5";
      cursor_blink_interval = "0.5";
      
      # Scrollback
      scrollback_lines = 10000;
      
      # Mouse
      mouse_hide_wait = "3.0";
      copy_on_select = "clipboard";
      
      # Performance
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = "yes";
      
      # Bell
      enable_audio_bell = "no";
      
      # Window
      window_padding_width = 8;
      hide_window_decorations = "yes";
      confirm_os_window_close = 0;
      
      # Tab bar
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
    };
  };
  
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
      # Quick shortcuts
      v = "nvim";
      c = "clear";
      q = "exit";
      
      # Power management
      zzz = "systemctl poweroff";
      reboot = "systemctl reboot";
      suspend = "systemctl suspend";
      
      # File listing (with eza if available, fallback to ls)
      ls = "eza --icons --group-directories-first 2>/dev/null || ls --color=auto";
      ll = "eza -la --icons --group-directories-first 2>/dev/null || ls -alF";
      la = "eza -a --icons 2>/dev/null || ls -A";
      l = "eza --icons 2>/dev/null || ls -CF";
      lt = "eza --tree --level=2 --icons 2>/dev/null || tree -L 2";
      
      # Better defaults
      cat = "bat";
      find = "fd";
      grep = "rg";
      top = "btop";
      df = "df -h";
      du = "du -h";
      free = "free -h";
      
      # NixOS system management
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config#mnemosyne";
      update = "sudo nix flake update ~/nixos-config && sudo nixos-rebuild switch --flake ~/nixos-config#mnemosyne";
      clean = "sudo nix-collect-garbage -d";
      search = "nix search nixpkgs";
      generations = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      
      # File operations (safe)
      cp = "cp -iv";
      mv = "mv -iv";
      rm = "rm -iv";
      mkdir = "mkdir -pv";
      
      # Directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "~" = "cd ~";
      "-" = "cd -";
      
      # Git shortcuts
      g = "git";
      ga = "git add";
      gaa = "git add --all";
      gc = "git commit";
      gcm = "git commit -m";
      gp = "git push";
      gl = "git pull";
      gs = "git status";
      gd = "git diff";
      gco = "git checkout";
      gb = "git branch";
      glog = "git log --oneline --graph --decorate";
      
      # Media
      music = "ncspot";
      play = "playerctl play-pause";
      next = "playerctl next";
      prev = "playerctl previous";
      stop = "playerctl stop";
      
      # Theme management
      wp = "~/.local/bin/wallpaper-manager";
      theme = "~/.config/hypr/scripts/theme-switcher.sh";
      
      # System info
      neofetch = "fastfetch";
      disk = "df -h";
      memory = "free -h";
    };
    
    initContent = ''
      # Source local zshrc if it exists (for machine-specific config)
      if [ -f ~/.zshrc.local ]; then
        source ~/.zshrc.local
      fi
      
      # Add local bin to path
      export PATH="$HOME/.local/bin:$PATH"
      
      # FZF integration
      if command -v fzf &>/dev/null; then
        # FZF options (colors inherited from terminal via Stylix)
        export FZF_DEFAULT_OPTS="--height=50% --layout=reverse --border --margin=1 --padding=1"
        
        # Use ripgrep for FZF if available
        if command -v rg &>/dev/null; then
          export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
          export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        fi
        
        # Preview with bat
        export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :200 {} 2>/dev/null || head -200 {}'"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
        export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {} 2>/dev/null || ls -la {}'"
      fi
      
      # History search with up/down arrows
      bindkey "^[[A" history-search-backward
      bindkey "^[[B" history-search-forward
    '';
  };
  
  # FZF integration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  
  # Starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromTOML (builtins.readFile ./dotfiles/starship.toml);
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
  # Cava Audio Visualizer
  # ═══════════════════════════════════════════════════════════════════
  
  xdg.configFile."cava/config".source = ./dotfiles/cava/config;

  # ═══════════════════════════════════════════════════════════════════
  # Fastfetch (System Info)
  # ═══════════════════════════════════════════════════════════════════
  
  xdg.configFile."fastfetch/config.jsonc".source = ./dotfiles/fastfetch/config.jsonc;

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
  # Note: Dynamic theming now handled by Stylix (modules/stylix.nix)
  # ═══════════════════════════════════════════════════════════════════

  # ═══════════════════════════════════════════════════════════════════
  # Git Configuration
  # ═══════════════════════════════════════════════════════════════════
  
  programs.git = {
    enable = true;
    
    settings = {
      user.name = "craig";  # Change to your name
      user.email = "your-email@example.com";  # Change to your email
      init.defaultBranch = "main";
      pull.rebase = false;
      core.editor = "nvim";
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # Neovim (with Lazy.nvim, Telescope, Treesitter, LSP)
  # ═══════════════════════════════════════════════════════════════════
  
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    
    # Dependencies for plugins (telescope, treesitter, etc.)
    extraPackages = with pkgs; [
      # Telescope dependencies
      ripgrep
      fd
      
      # Treesitter
      tree-sitter
      gcc  # for treesitter compilation
      
      # LSP servers
      lua-language-server
      nil  # Nix LSP
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted  # HTML/CSS/JSON
      pyright  # Python
      rust-analyzer
      
      # Formatters
      stylua
      nixpkgs-fmt
      prettierd
      black
      
      # Other tools
      lazygit  # for lazygit.nvim
    ];
  };
  
  # Neovim config directory (your full Arch config with lazy.nvim)
  xdg.configFile."nvim" = {
    source = ./dotfiles/nvim;
    recursive = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # Tmux (Stylix handles colors)
  # ═══════════════════════════════════════════════════════════════════
  
  programs.tmux = {
    enable = true;
    # Stylix injects colors; we keep custom keybinds/behavior via extraConfig
  };
  
  # Custom tmux config (keybinds, behavior - Stylix handles colors)
  home.file.".tmux.conf".source = ./dotfiles/tmux/.tmux.conf;
  xdg.configFile."tmux/tmux-music.conf".source = ./dotfiles/tmux/tmux-music.conf;

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
