# System-wide packages configuration
# Translated from Ansible packages and AUR packages

{ config, pkgs, ... }:

{
  # Allow unfree packages (VSCode, Discord, etc.)
  nixpkgs.config.allowUnfree = true;

  # ═══════════════════════════════════════════════════════════════════
  # Core System Packages
  # ═══════════════════════════════════════════════════════════════════
  
  environment.systemPackages = with pkgs; [
    # ─────────────────────────────────────────────────────────────────
    # Terminal & Shell Utilities
    # ─────────────────────────────────────────────────────────────────
    zsh
    oh-my-zsh
    starship       # Shell prompt
    tmux
    kitty          # Terminal emulator
    
    # CLI Tools
    bat            # Better cat
    eza            # Better ls
    fd             # Better find
    ripgrep        # Better grep
    fzf            # Fuzzy finder
    zoxide         # Better cd
    btop           # System monitor
    htop
    fastfetch      # System info
    neofetch
    
    # File managers
    ranger
    nnn
    thunar
    
    # Archive tools
    unzip
    zip
    p7zip
    unrar
    
    # ─────────────────────────────────────────────────────────────────
    # Development Tools
    # ─────────────────────────────────────────────────────────────────
    neovim
    vscode
    git
    gh             # GitHub CLI
    
    # Build tools
    gcc
    clang
    cmake
    gnumake
    
    # Programming languages
    python3
    python311Packages.pip
    python311Packages.setuptools
    nodejs
    rustup
    
    # ─────────────────────────────────────────────────────────────────
    # Browsers
    # ─────────────────────────────────────────────────────────────────
    librewolf
    brave
    firefox        # Wayland enabled via MOZ_ENABLE_WAYLAND=1 in niri.nix
    
    # ─────────────────────────────────────────────────────────────────
    # Media & Audio
    # ─────────────────────────────────────────────────────────────────
    # Audio
    pipewire
    wireplumber
    pavucontrol
    playerctl
    pamixer        # CLI audio control (used by Niri keybindings)
    cava           # Audio visualizer
    
    # Music players
    ncmpcpp
    ncspot         # Spotify TUI
    
    # MPD
    mpd
    mpc            # MPD client (renamed from mpc-cli)
    
    # Video
    mpv
    vlc
    
    # Image viewers
    imv
    feh
    
    # Screen recording
    obs-studio
    
    # ─────────────────────────────────────────────────────────────────
    # System Utilities
    # ─────────────────────────────────────────────────────────────────
    # Network
    networkmanagerapplet
    wget
    curl
    rsync
    
    # Disk utilities
    gparted
    dosfstools
    ntfs3g
    
    # System monitoring
    lm_sensors
    
    # Power management
    powertop
    
    # USB utilities
    usbutils
    udiskie    # Automount USB drives (used by niri startup)
    
    # ─────────────────────────────────────────────────────────────────
    # Theming & Appearance
    # ─────────────────────────────────────────────────────────────────
    # GTK themes
    adw-gtk3         # Adwaita GTK3 theme
    arc-theme
    nordic           # Nordic theme
    
    # Icon themes
    papirus-icon-theme
    
    # Cursor themes
    nordzy-cursor-theme   # From your AUR list (renamed from nordzy-cursors)
    
    # Wallpaper tools
    wallust        # Better pywal - available in nixpkgs!
    
    # ─────────────────────────────────────────────────────────────────
    # Office & Productivity
    # ─────────────────────────────────────────────────────────────────
    libreoffice
    
    # PDF viewers
    zathura
    evince
    
    # ─────────────────────────────────────────────────────────────────
    # Communication
    # ─────────────────────────────────────────────────────────────────
    discord
    telegram-desktop
    
    # ─────────────────────────────────────────────────────────────────
    # Fun/Eye-candy (from your AUR packages)
    # ─────────────────────────────────────────────────────────────────
    cmatrix
    pipes
    cbonsai         # May need to check nixpkgs
    
    # ─────────────────────────────────────────────────────────────────
    # Additional tools from your setup
    # ─────────────────────────────────────────────────────────────────
    qt5ct          # Qt5 configuration tool
    lxappearance   # GTK theme switcher
  ];

  # ═══════════════════════════════════════════════════════════════════
  # Additional Programs
  # ═══════════════════════════════════════════════════════════════════
  
  # Zsh as default shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  
  # Git configuration
  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
    };
  };
  
  # Thunar with plugins
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-volman
      thunar-archive-plugin
    ];
  };
  
  # File manager support
  programs.xfconf.enable = true;
  services.tumbler.enable = true;  # Thumbnails for Thunar
}
