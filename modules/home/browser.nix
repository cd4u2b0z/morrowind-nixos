# Home Module: Browser
#
# Librewolf, Brave, and browser-related config.
#
# Extracted from: home/default.nix

{ config, lib, pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════════════
  # Librewolf Browser
  # ═══════════════════════════════════════════════════════════════════
  
  programs.librewolf = {
    enable = true;
    
    # Profile for Stylix theming
    profiles.default = {
      id = 0;
      isDefault = true;
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
      };
    };
    
    # Policies (system-wide settings)
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxAccounts = false;  # Allow sync if you want
      DisableSetDesktopBackground = true;
      
      # Hardware acceleration
      HardwareAcceleration = true;
      
      # Extensions to install (use extension IDs from addons.mozilla.org)
      ExtensionSettings = {
        # uBlock Origin
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        # Bitwarden
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
        # Dark Reader
        "addon@darkreader.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          installation_mode = "force_installed";
        };
        # Canvas Blocker
        "CanvasBlocker@kkapsner.de" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/canvasblocker/latest.xpi";
          installation_mode = "force_installed";
        };
        # Decentraleyes
        "jid1-BoFifL9Vbdl2zQ@jetpack" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/decentraleyes/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # Brave browser with Wayland flags
  # ═══════════════════════════════════════════════════════════════════
  
  xdg.desktopEntries.brave-browser = {
    name = "Brave";
    genericName = "Web Browser";
    exec = "brave --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime %U";
    icon = "brave";
    terminal = false;
    categories = [ "Network" "WebBrowser" ];
    mimeType = [ "text/html" "text/xml" "application/xhtml+xml" ];
  };
  
  # Chromium/Electron Wayland flags
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
