# Module: Packages
#
# System-wide packages, fonts, and program configs.
#
# Extracted from: modules/packages.nix

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
    yazi           # Terminal file manager (Morrowind themed)
    nnn
    thunar
    
    # Keyring and secrets (for VSCode auth, etc.)
    gnome-keyring
    libsecret
    seahorse  # GUI for managing keyring
    xdg-utils # For xdg-open (VSCode auth browser popup)
    
    # Archive tools
    unzip
    zip
    p7zip
    unrar
    
    # ─────────────────────────────────────────────────────────────────
    # Development Tools
    # ─────────────────────────────────────────────────────────────────
    neovim
    zed-editor
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
    brave
    firefox
    
    # ─────────────────────────────────────────────────────────────────
    # Media & Audio
    # ─────────────────────────────────────────────────────────────────
    spotify
    cava           # Audio visualizer
    
    # Music players
    ncmpcpp
    ncspot         # Spotify TUI
    
    # MPD
    mpd
    mpc
    
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
    jq  # JSON parsing for scripts
    
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
    udiskie    # Automount USB drives
    
    # ─────────────────────────────────────────────────────────────────
    # Theming & Appearance
    # ─────────────────────────────────────────────────────────────────
    # GTK themes
    adw-gtk3
    arc-theme
    nordic
    
    # Icon themes
    papirus-icon-theme
    
    # Cursor themes
    nordzy-cursor-theme
    
    # Wallpaper tools
    wallust        # Better pywal
    swww           # Animated wallpaper daemon
    
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
    # Fun/Eye-candy
    # ─────────────────────────────────────────────────────────────────
    cmatrix
    pipes
    cbonsai
    asciiquarium
    lavat
    sl
    fortune
    cowsay
    lolcat
    
    # ─────────────────────────────────────────────────────────────────
    # Additional tools
    # ─────────────────────────────────────────────────────────────────
    libsForQt5.qt5ct
    lxappearance
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
    plugins = with pkgs; [
      thunar-volman
      thunar-archive-plugin
    ];
  };
  
  # File manager support
  programs.xfconf.enable = true;
  services.tumbler.enable = true;  # Thumbnails for Thunar
  
  # ═══════════════════════════════════════════════════════════════════
  # Font Configuration
  # ═══════════════════════════════════════════════════════════════════
  
  fonts.packages = with pkgs; [
    # Nerd Fonts (for terminal/waybar icons)
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.symbols-only
    
    # System fonts
    inter
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    font-awesome
    
    # Additional fonts
    liberation_ttf
    ubuntu-classic
  ];
  
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" "Hack Nerd Font" "Fira Code" ];
      sansSerif = [ "Inter" "Noto Sans" ];
      serif = [ "Noto Serif" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
