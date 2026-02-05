# Module: Core System
#
# Foundational system configuration that every machine needs.
# Users, locale, timezone, Nix settings, security basics.
#
# Extracted from: modules/system.nix

{ config, lib, pkgs, username, ... }:

{
  # ═══════════════════════════════════════════════════════════════════
  # System Basics
  # ═══════════════════════════════════════════════════════════════════
  
  system.stateVersion = "24.05";

  # ═══════════════════════════════════════════════════════════════════
  # User Configuration
  # ═══════════════════════════════════════════════════════════════════
  
  users.users.${username} = {
    isNormalUser = true;
    description = "Craig";
    
    extraGroups = [
      "wheel"        # sudo access
      "networkmanager"
      "audio"
      "video"
      "input"
      "bluetooth"
      "plugdev"
      # "docker"     # Uncomment if you use Docker
      # "libvirtd"   # Uncomment if you use virtualization
    ];
    
    shell = pkgs.zsh;
  };
  
  # Enable sudo without password for wheel group
  security.sudo.wheelNeedsPassword = false;

  # ═══════════════════════════════════════════════════════════════════
  # Locale & Time
  # ═══════════════════════════════════════════════════════════════════
  
  time.timeZone = "America/New_York";
  
  i18n = {
    defaultLocale = "en_US.UTF-8";
    
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # Console Configuration
  # ═══════════════════════════════════════════════════════════════════
  
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # ═══════════════════════════════════════════════════════════════════
  # Nix Configuration
  # ═══════════════════════════════════════════════════════════════════
  
  nix = {
    settings = {
      # Enable flakes
      experimental-features = [ "nix-command" "flakes" ];
      
      # Optimize storage
      auto-optimise-store = true;
      
      # Trusted users
      trusted-users = [ "root" username ];
      
      # Substituters for faster downloads
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    
    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # Security
  # ═══════════════════════════════════════════════════════════════════
  
  security = {
    rtkit.enable = true;  # RealtimeKit for audio
    polkit.enable = true;
    
    # PAM configuration for swaylock
    pam.services.swaylock = {};
  };

  # ═══════════════════════════════════════════════════════════════════
  # Documentation
  # ═══════════════════════════════════════════════════════════════════
  
  documentation = {
    enable = true;
    dev.enable = true;
    man.enable = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # XDG User Directories
  # ═══════════════════════════════════════════════════════════════════
  
  environment.sessionVariables = {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };
}
