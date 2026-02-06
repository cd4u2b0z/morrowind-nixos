# Home Module: Browser
#
# Librewolf, Brave, and browser-related config.
#
# Extracted from: home/default.nix

{ config, lib, pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════════════
  # Wayland Environment Variables for Browsers
  # ═══════════════════════════════════════════════════════════════════
  
  home.sessionVariables = {
    # Firefox/Librewolf Wayland
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_USE_XINPUT2 = "1";
    
    # General Wayland for GTK/Qt apps
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    
    # Chromium/Electron Wayland
    NIXOS_OZONE_WL = "1";
  };

  # ═══════════════════════════════════════════════════════════════════
  # Librewolf Browser
  # ═══════════════════════════════════════════════════════════════════
  
  programs.librewolf = {
    enable = true;
    
    # Profile for Stylix theming
    profiles.default = {
      id = 0;
      isDefault = true;
      
      # Extensions via NUR
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        darkreader
        bitwarden
        decentraleyes
        canvasblocker
      ];
      
      settings = {
        # Hardware video acceleration (VA-API)
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;
        
        # Wayland native
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "widget.use-xdg-desktop-portal.mime-handler" = 1;
        
        # Smooth scrolling
        "general.smoothScroll" = true;
        
        # Enable extensions
        "extensions.autoDisableScopes" = 0;
      };
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # Brave browser with Wayland flags
  # ═══════════════════════════════════════════════════════════════════
  
  xdg.desktopEntries.brave-browser = {
    name = "Brave";
    genericName = "Web Browser";
    exec = "brave --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland --enable-wayland-ime --disable-features=CrashpadOOPReporting %U";
    icon = "brave";
    terminal = false;
    categories = [ "Network" "WebBrowser" ];
    mimeType = [ "text/html" "text/xml" "application/xhtml+xml" ];
  };
  
  # Chromium/Electron Wayland flags
  xdg.configFile."chromium-flags.conf".text = ''
    --enable-features=UseOzonePlatform,WaylandWindowDecorations
    --ozone-platform=wayland
    --enable-wayland-ime
    --disable-features=CrashpadOOPReporting
  '';
  
  xdg.configFile."brave-flags.conf".text = ''
    --enable-features=UseOzonePlatform,WaylandWindowDecorations
    --ozone-platform=wayland
    --enable-wayland-ime
    --disable-features=CrashpadOOPReporting
  '';
  
  xdg.configFile."electron-flags.conf".text = ''
    --enable-features=UseOzonePlatform,WaylandWindowDecorations
    --ozone-platform=wayland
    --enable-wayland-ime
  '';
  
  xdg.configFile."electron13-flags.conf".text = ''
    --enable-features=UseOzonePlatform
    --ozone-platform=wayland
  '';

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
