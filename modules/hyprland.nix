# Hyprland Compositor Configuration
# Wayland compositor and desktop environment settings

{ config, lib, pkgs, inputs, ... }:

{
  # ═══════════════════════════════════════════════════════════════════
  # Hyprland Compositor
  # ═══════════════════════════════════════════════════════════════════
  
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
  };

  # ═══════════════════════════════════════════════════════════════════
  # XDG Portal Configuration
  # ═══════════════════════════════════════════════════════════════════
  
  xdg.portal = {
    enable = true;
    wlr.enable = false;  # We use the Hyprland portal instead
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      hyprland = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      };
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # Hyprland Ecosystem Packages
  # ═══════════════════════════════════════════════════════════════════
  
  environment.systemPackages = with pkgs; [
    # Hyprland ecosystem
    hyprlock          # Screen locker for Hyprland
    hypridle          # Idle manager for Hyprland
    hyprpaper         # Wallpaper utility for Hyprland
    hyprpicker        # Color picker for Hyprland
    
    # Wayland utilities
    wl-clipboard      # Clipboard utilities
    wlr-randr         # Display configuration
    wl-gammarelay-rs  # Night light / gamma control
    cliphist          # Clipboard history
    
    # Screenshot & screen recording
    grim              # Screenshot utility
    slurp             # Screen region selector
    wf-recorder       # Screen recorder
    swappy            # Screenshot annotation
    
    # Wayland session utilities
    wlogout           # Logout menu
    wdisplays         # Display configuration GUI
    
    # Additional utilities
    libnotify         # Notification sending
    brightnessctl     # Screen brightness control
    playerctl         # Media player control
    pamixer           # Audio volume control
    
    # SDDM theme
    (catppuccin-sddm.override {
      flavor = "mocha";
      font = "Noto Sans";
      fontSize = "12";
    })
  ];

  # ═══════════════════════════════════════════════════════════════════
  # Security - Hyprlock PAM Authentication
  # ═══════════════════════════════════════════════════════════════════
  
  # Required for hyprlock to authenticate
  security.pam.services.hyprlock = {};

  # ═══════════════════════════════════════════════════════════════════
  # Environment Variables for Wayland
  # ═══════════════════════════════════════════════════════════════════
  
  environment.sessionVariables = {
    # Wayland/Hyprland session
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    
    # Graphics
    NIXOS_OZONE_WL = "1";           # Enable Ozone Wayland for Chromium/Electron
    MOZ_ENABLE_WAYLAND = "1";        # Firefox native Wayland
    GDK_BACKEND = "wayland,x11";     # GTK prefer Wayland
    QT_QPA_PLATFORM = "wayland;xcb"; # Qt prefer Wayland
    SDL_VIDEODRIVER = "wayland";     # SDL use Wayland
    CLUTTER_BACKEND = "wayland";     # Clutter use Wayland
    
    # Cursor
    XCURSOR_SIZE = "24";
    
    # Qt theming
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };

  # ═══════════════════════════════════════════════════════════════════
  # Polkit Authentication Agent
  # ═══════════════════════════════════════════════════════════════════
  
  # GNOME Polkit agent for GUI authentication prompts
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
  # SDDM Display Manager (Wayland)
  # ═══════════════════════════════════════════════════════════════════
  
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-mocha";
    package = pkgs.kdePackages.sddm;
  };
}
