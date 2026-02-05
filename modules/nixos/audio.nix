# Module: Audio
#
# PipeWire configuration for audio/video.
#
# Extracted from: modules/services.nix

{ config, lib, pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════════════
  # Audio (PipeWire)
  # ═══════════════════════════════════════════════════════════════════

  # Disable PulseAudio (using PipeWire instead)
  services.pulseaudio.enable = false;
  
  # Enable PipeWire
  services.pipewire = {
    enable = true;
    
    alsa = {
      enable = true;
      support32Bit = true;
    };
    
    pulse.enable = true;
    jack.enable = true;
    
    # Low-latency configuration
    extraConfig.pipewire = {
      "10-clock-rate" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 1024;
          "default.clock.min-quantum" = 512;
          "default.clock.max-quantum" = 2048;
        };
      };
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # Audio Packages
  # ═══════════════════════════════════════════════════════════════════
  
  environment.systemPackages = with pkgs; [
    pipewire
    wireplumber
    pavucontrol
    playerctl
    pamixer        # CLI audio control
  ];
}
