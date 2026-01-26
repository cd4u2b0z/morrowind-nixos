# Hardware configuration for ASUS Vivobook S15
# CPU: Intel Core i7-8565U (Whiskey Lake, 8th Gen)
# GPU: Intel UHD Graphics 620
# RAM: 8GB
#
# This file should be generated during installation with:
#   nixos-generate-config --root /mnt
# Then copy it here and customize as needed

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # ═══════════════════════════════════════════════════════════════════
  # Boot Configuration
  # ═══════════════════════════════════════════════════════════════════
  
  boot = {
    # Kernel - use latest for best Intel support
    kernelPackages = pkgs.linuxPackages_latest;
    
    # Kernel modules for Intel Whiskey Lake
    initrd = {
      availableKernelModules = [ 
        "xhci_pci"        # USB 3.0
        "ahci"            # SATA
        "nvme"            # NVMe SSD
        "usb_storage"     # USB storage
        "sd_mod"          # SD card
        "rtsx_pci_sdmmc"  # Realtek SD card reader (common on ASUS)
        "i915"            # Intel integrated graphics
      ];
      kernelModules = [ "i915" ];  # Load Intel GPU early for smooth boot
    };
    
    kernelModules = [ "kvm-intel" "iwlwifi" ];  # Intel virtualization + WiFi
    extraModulePackages = [ ];
    
    # Intel GPU kernel parameters for better performance
    kernelParams = [
      "i915.enable_fbc=1"           # Framebuffer compression (saves power)
      "i915.enable_psr=1"           # Panel Self Refresh (saves power on eDP)
      "i915.fastboot=1"             # Skip unnecessary mode switches
      
      # ASUS laptop ACPI compatibility
      "acpi_osi=Linux"              # Tell ACPI we're Linux (helps with some quirks)
      "acpi_backlight=native"       # Use native backlight control
      
      # Suppress harmless ASUS firmware bug warnings
      "tsc=reliable"                # Trust TSC despite firmware bugs
      "clocksource=tsc"             # Use TSC as clocksource
      "acpi_enforce_resources=lax"  # Reduce ACPI resource conflict warnings
      
      # Reduce kernel log verbosity for known harmless warnings
      "loglevel=4"                  # Show warnings but reduce ACPI spam at boot
      
      # Plymouth display - use main laptop screen only (not ScreenPad)
      "video=eDP-1:1920x1080@60"    # Primary display for boot splash
    ];
    
    # Bootloader - UEFI with systemd-boot
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;  # Keep last 10 generations
        editor = false;  # Security: disable boot editor
      };
      efi.canTouchEfiVariables = true;
      timeout = 3;  # 3 second boot menu
    };
    
    # Enable Plymouth for beautiful boot splash
    plymouth.enable = true;
  };

  # ═══════════════════════════════════════════════════════════════════
  # Filesystems
  # ═══════════════════════════════════════════════════════════════════
  
  # Filesystem UUIDs from lsblk -f on the ASUS Vivobook S15
  
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/8d1e7ce0-5184-43a3-bc2a-a9c86737335d";
    fsType = "ext4";
    options = [ "noatime" ];  # Performance optimization
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A45D-FCFE";
    fsType = "vfat";
  };

  # No swap partition - using zramSwap instead (configured below)
  swapDevices = [ ];

  # ═══════════════════════════════════════════════════════════════════
  # Hardware Optimization - Intel i7-8565U + UHD 620
  # ═══════════════════════════════════════════════════════════════════
  
  # Intel CPU microcode updates (CRITICAL for Spectre/Meltdown mitigations)
  hardware.cpu.intel.updateMicrocode = true;
  
  # Enable firmware updates
  services.fwupd.enable = true;
  
  # Intel UHD 620 Graphics Configuration
  # NOTE: hardware.graphics replaces deprecated hardware.opengl on NixOS 24.05+
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # For 32-bit applications (legacy software)
    
    extraPackages = with pkgs; [
      intel-media-driver    # VAAPI driver for Intel Gen 8+ (UHD 620) - recommended
      intel-vaapi-driver    # Older VAAPI driver (fallback)
      libva-vdpau-driver    # VDPAU compatibility layer (renamed from vaapiVdpau)
      libvdpau-va-gl        # VDPAU backend for VAAPI
      intel-compute-runtime # OpenCL support
    ];
    
    # For 32-bit applications (legacy software)
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
      intel-vaapi-driver
    ];
  };
  
  # Environment variables for Intel GPU
  environment.variables = {
    LIBVA_DRIVER_NAME = "iHD";  # Use newer Intel media driver
  };
  
  # Power management for Intel laptops
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";  # Intel P-state uses powersave by default
  };
  
  # Laptop-specific services
  services = {
    # TLP for battery optimization (Intel-specific settings)
    tlp = {
      enable = true;
      settings = {
        # Intel P-state driver settings
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        
        # Intel Turbo Boost
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        
        # Intel HWP (Hardware P-states) - available on i7-8565U
        CPU_HWP_ON_AC = "performance";
        CPU_HWP_ON_BAT = "power";
        
        # PCIe power management
        PCIE_ASPM_ON_BAT = "powersupersave";
        
        # WiFi power saving
        WIFI_PWR_ON_BAT = "on";
        
        # Intel GPU power management
        INTEL_GPU_MIN_FREQ_ON_AC = 0;
        INTEL_GPU_MIN_FREQ_ON_BAT = 0;
        INTEL_GPU_MAX_FREQ_ON_AC = 1100;  # UHD 620 max is 1.1 GHz
        INTEL_GPU_MAX_FREQ_ON_BAT = 600;
        INTEL_GPU_BOOST_FREQ_ON_AC = 1100;
        INTEL_GPU_BOOST_FREQ_ON_BAT = 800;
      };
    };
    
    # Intel thermald for thermal management (ESSENTIAL for ultrabooks)
    thermald.enable = true;
    
    # Auto-mount USB drives
    udisks2.enable = true;
  };
  
  # ═══════════════════════════════════════════════════════════════════
  # Networking Hardware
  # ═══════════════════════════════════════════════════════════════════
  
  # WiFi - Intel Wireless (common on Vivobook S15)
  # The i7-8565U model typically has Intel Wireless-AC 9560 or similar
  hardware.wirelessRegulatoryDatabase = true;
  
  # Enable Intel firmware for WiFi
  hardware.enableRedistributableFirmware = true;
  
  # Intel WiFi power management (disable to prevent connection drops)
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0
    options iwlmvm power_scheme=1
  '';
  
  # ═══════════════════════════════════════════════════════════════════
  # Memory Optimization for 8GB RAM
  # ═══════════════════════════════════════════════════════════════════
  
  # Enable zram for better memory management with limited RAM
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;  # Use up to 4GB as compressed swap
  };
  
  # Tune kernel for lower RAM
  boot.kernel.sysctl = {
    "vm.swappiness" = 60;           # Moderate swap usage
    "vm.vfs_cache_pressure" = 50;   # Balance inode/dentry cache
    "vm.dirty_ratio" = 10;          # Reduce dirty page ratio for stability
    "vm.dirty_background_ratio" = 5;
  };
  
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
