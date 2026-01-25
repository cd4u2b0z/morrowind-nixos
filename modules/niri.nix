# Niri Compositor Configuration
# Replacing Hyprland with Niri while keeping the same Wayland ecosystem

{ config, lib, pkgs, username, ... }:

{
  # Enable Niri compositor
  programs.niri = {
    enable = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # Wayland Environment Variables (same as your Hyprland setup)
  # ═══════════════════════════════════════════════════════════════════
  
  environment.sessionVariables = {
    # XDG Desktop Portal
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    
    # Qt/GTK theming
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    GTK_THEME = "adw-gtk3-dark";
    ADW_DEBUG_COLOR_SCHEME = "prefer-dark";
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1";
    
    # Wayland-specific for browsers
    MOZ_ENABLE_WAYLAND = "1";        # Firefox/LibreWolf native Wayland
    NIXOS_OZONE_WL = "1";            # Electron apps use Wayland
    
    # Chromium-based browsers (Brave, Chrome, Chromium, Edge)
    # These use the flags files in ~/.config/ but we set fallback env vars too
    CHROME_OZONE_PLATFORM = "wayland";
    
    # Cursor theme
    XCURSOR_THEME = "Nordzy-cursors";
    XCURSOR_SIZE = "24";
  };

  # ═══════════════════════════════════════════════════════════════════
  # XDG Desktop Portal (required for screen sharing, Flatpak, etc.)
  # ═══════════════════════════════════════════════════════════════════
  
  xdg.portal = {
    enable = true;
    
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome  # Recommended for Niri - better screencasting
    ];
    
    config = {
      niri = {
        default = [ "gnome" "gtk" ];
      };
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # Wayland Ecosystem Packages (matching your Hyprland setup)
  # ═══════════════════════════════════════════════════════════════════
  
  environment.systemPackages = with pkgs; [
    # Status bar (you currently use Waybar)
    waybar
    
    # Notification daemon (you currently use Mako)
    mako
    libnotify  # For notify-send command
    
    # Application launcher (you currently use Fuzzel)
    fuzzel
    
    # Screen locker (alternative to hyprlock)
    swaylock-effects
    
    # Idle manager (alternative to hypridle)
    swayidle
    
    # Screenshot tools
    grim        # Screenshot utility
    slurp       # Screen area selection
    wl-clipboard  # Clipboard manager
    
    # Color picker
    hyprpicker  # Works with any Wayland compositor
    
    # Wallpaper setter
    swaybg
    
    # Display configuration
    wdisplays  # GUI tool
    wlr-randr  # CLI tool
    
    # Brightness control
    brightnessctl
    
    # Audio control
    pavucontrol
    playerctl
    
    # Clipboard manager
    cliphist
    
    # System info (you have nwg-displays)
    nwg-displays
    
    # XWayland bridge for X11 apps (Steam, Discord, etc.)
    # CRITICAL: Without this, X11 apps won't work in Niri!
    xwayland-satellite
    
    # Secret service for credentials (gnome-keyring or seahorse)
    gnome-keyring
    seahorse  # GUI for gnome-keyring
  ];

  # ═══════════════════════════════════════════════════════════════════
  # Graphics & Session
  # ═══════════════════════════════════════════════════════════════════
  
  # Enable display manager with Wayland session
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
      };
    };
  };
  
  # Polkit authentication agent
  security.polkit.enable = true;
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # Fonts (matching your setup)
  # ═══════════════════════════════════════════════════════════════════
  
  fonts = {
    enableDefaultPackages = true;
    
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      font-awesome
      (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" "Iosevka" ]; })
    ];
    
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
