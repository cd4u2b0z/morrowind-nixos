# Module: Services
#
# Bluetooth, printing, SSH, daemons, misc services.
#
# Extracted from: modules/services.nix

{ config, lib, pkgs, ... }:

{
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

  # ═══════════════════════════════════════════════════════════════════
  # GNOME Keyring - for browser passwords, VSCode auth, SSH keys
  # ═══════════════════════════════════════════════════════════════════
  
  services.gnome.gnome-keyring.enable = true;
  
  # Auto-unlock keyring at login (for TTY + Hyprland workflow)
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
}
