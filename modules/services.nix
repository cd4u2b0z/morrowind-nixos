# Services configuration
# NetworkManager, Bluetooth, Audio, etc.

{ config, lib, pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════════════
  # Network Services
  # ═══════════════════════════════════════════════════════════════════
  
  networking = {
    networkmanager = {
      enable = true;
      wifi.powersave = false;  # Prevents WiFi disconnects
    };
    
    # Firewall
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      
      # Allow KDE Connect, Syncthing, etc. if needed
      allowedTCPPortRanges = [
        # { from = 1714; to = 1764; }  # KDE Connect
      ];
      allowedUDPPortRanges = [
        # { from = 1714; to = 1764; }  # KDE Connect
      ];
    };
  };

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
  # Bluetooth (from your Ansible config)
  # ═══════════════════════════════════════════════════════════════════
  
  services.blueman.enable = true;

  # ═══════════════════════════════════════════════════════════════════
  # Printing (CUPS)
  # ═══════════════════════════════════════════════════════════════════
  
  services.printing = {
    enable = true;
    drivers = with pkgs; [ gutenprint hplip ];
  };
  
  # Printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # Display Manager (greetd with tuigreet)
  # ═══════════════════════════════════════════════════════════════════
  
  # Already configured in niri.nix, but included here for reference

  # ═══════════════════════════════════════════════════════════════════
  # SSH (optional)
  # ═══════════════════════════════════════════════════════════════════
  
  services.openssh = {
    enable = false;  # Set to true if you need SSH
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # Scheduled Tasks (Cron equivalent)
  # ═══════════════════════════════════════════════════════════════════
  
  services.cron = {
    enable = true;
    systemCronJobs = [
      # Add your cron jobs here
      # Example: "0 2 * * * root /path/to/script"
    ];
  };

  # ═══════════════════════════════════════════════════════════════════
  # User Services (systemd user services)
  # ═══════════════════════════════════════════════════════════════════
  
  # MPD (Music Player Daemon) as user service
  systemd.user.services.mpd = {
    description = "Music Player Daemon";
    after = [ "network.target" "sound.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "notify";
      ExecStart = "${pkgs.mpd}/bin/mpd --no-daemon";
      Restart = "on-failure";
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # GVFS (for Thunar and file manager functionality)
  # ═══════════════════════════════════════════════════════════════════
  
  services.gvfs.enable = true;

  # ═══════════════════════════════════════════════════════════════════
  # D-Bus
  # ═══════════════════════════════════════════════════════════════════
  
  services.dbus.enable = true;

  # ═══════════════════════════════════════════════════════════════════
  # GNOME Keyring - for VSCode auth, SSH keys, secrets storage
  # ═══════════════════════════════════════════════════════════════════
  
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;
  
  # ═══════════════════════════════════════════════════════════════════
  # Bluetooth
  # ═══════════════════════════════════════════════════════════════════
  
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # Location services (for redshift/night light)
  # ═══════════════════════════════════════════════════════════════════
  
  location.provider = "geoclue2";
  services.geoclue2.enable = true;

  # ═══════════════════════════════════════════════════════════════════
  # Automatic system updates (optional)
  # ═══════════════════════════════════════════════════════════════════
  
  system.autoUpgrade = {
    enable = false;  # Set to true if you want automatic updates
    flake = "/home/craig/projects/nixos-asus-vivobook";
    flags = [ "--update-input" "nixpkgs" ];
    dates = "weekly";
  };

  # ═══════════════════════════════════════════════════════════════════
  # Virtualization (optional)
  # ═══════════════════════════════════════════════════════════════════
  
  virtualisation = {
    # Docker
    docker = {
      enable = false;  # Set to true if you use Docker
      enableOnBoot = false;
    };
    
    # Libvirt/KVM
    libvirtd = {
      enable = false;  # Set to true if you use VMs
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [ pkgs.OVMFFull.fd ];
        };
      };
    };
  };
}
