# NixOS Configuration for ASUS Vivobook S15 with Hyprland

A complete NixOS flake-based configuration for ASUS Vivobook S15 (Intel i7-8565U + UHD 620), featuring the **Hyprland scrollable-tiling Wayland compositor**. This is a complete translation of an Arch Linux + Hyprland setup to NixOS + Hyprland with **identical look and feel**.

---

## 📋 Table of Contents

1. [Overview](#-overview)
2. [Hardware Requirements](#-hardware-requirements)
3. [Project Structure](#-project-structure)
4. [Pre-Installation Checklist](#-pre-installation-checklist)
5. [Step-by-Step Installation](#-step-by-step-installation)
6. [Post-Installation Setup](#-post-installation-setup)
7. [Testing & Validation](#-testing--validation)
8. [Troubleshooting Guide](#-troubleshooting-guide)
9. [Daily Usage Commands](#-daily-usage-commands)
10. [Keybindings Reference](#-keybindings-reference)
11. [Customization](#-customization)
12. [Rollback & Recovery](#-rollback--recovery)

---

## 🌟 Overview

### What's Included

| Component | Description |
|-----------|-------------|
| **Hyprland** | Scrollable-tiling Wayland compositor (Hyprland alternative) |
| **Waybar** | Status bar with workspaces, weather, music, system stats |
| **Mako** | Notification daemon (Nord themed) |
| **Fuzzel** | Application launcher (Nord themed) |
| **Kitty** | GPU-accelerated terminal |
| **Hyprlock** | Screen locker with blur effects |
| **Starship** | Cross-shell prompt |
| **PipeWire** | Modern audio server |
| **TLP** | Battery optimization for laptops |

### Theme
- **Color Scheme**: Nord
- **GTK Theme**: adw-gtk3-dark
- **Icons**: Papirus-Dark
- **Cursor**: Nordzy-cursors
- **Font**: Inter, JetBrainsMono Nerd Font

---

## 💻 Hardware Requirements

This configuration is optimized for:

| Component | Specification |
|-----------|--------------|
| **CPU** | Intel Core i7-8565U (Whiskey Lake) |
| **GPU** | Intel UHD Graphics 620 |
| **RAM** | 8GB (zram compression enabled) |
| **Storage** | NVMe SSD recommended |
| **Display** | 1920x1080 @ 60Hz |

> ⚠️ **Note**: If you have different hardware (AMD, NVIDIA, more RAM), you'll need to modify `hardware-configuration.nix`.

---

## 📂 Project Structure

```
nixos-asus-mnemosyne/
├── flake.nix                          # Main flake entry point
├── flake.lock                         # Locked dependencies (generated)
├── hardware-configuration.nix         # Hardware-specific settings
├── modules/
│   ├── system.nix                     # User, locale, Nix settings
│   ├── hyprland.nix                       # Hyprland compositor & Wayland
│   ├── packages.nix                   # All system packages
│   └── services.nix                   # System services
├── home/
│   ├── default.nix                    # Home Manager config
│   └── dotfiles/
│       ├── hyprland/
│       │   ├── hyprland.conf             # Hyprland keybindings & settings
│       │   └── scripts/               # Wallpaper, screenshot, etc.
│       ├── waybar/
│       │   ├── config                 # Waybar modules
│       │   ├── style.css              # Waybar styling
│       │   ├── wallust-colors.css     # Dynamic colors
│       │   └── scripts/               # Weather, music, stats, etc.
│       ├── kitty/kitty.conf           # Terminal config
│       ├── mako/config                # Notifications
│       ├── fuzzel/fuzzel.ini          # Launcher
│       ├── hyprlock/config            # Lock screen
│       └── starship.toml              # Shell prompt
├── README.md                          # This file
├── QUICKSTART.md                      # Quick reference
└── PACKAGE-MAPPING.md                 # Arch → NixOS package mapping
```

---

## ✅ Pre-Installation Checklist

Before starting, ensure you have:

- [ ] **Backup important data** - NixOS installation will format your drive
- [ ] **NixOS ISO** downloaded from [nixos.org](https://nixos.org/download.html) (use minimal ISO)
- [ ] **Bootable USB** created with the ISO
- [ ] **Internet connection** (Ethernet recommended for installation)
- [ ] **UEFI mode** enabled in BIOS (disable Secure Boot)
- [ ] **This repository** accessible (GitHub or USB copy)

### Create Bootable USB

```bash
# On Linux/Mac
sudo dd if=nixos-minimal-*.iso of=/dev/sdX bs=4M status=progress conv=fsync

# On Windows - use Rufus or Etcher
```

---

## 🚀 Step-by-Step Installation

### Phase 1: Boot & Network Setup

```bash
# 1. Boot from USB and wait for shell prompt

# 2. Set up WiFi (if no Ethernet)
sudo systemctl start wpa_supplicant
wpa_cli
> add_network
> set_network 0 ssid "YourWiFiName"
> set_network 0 psk "YourPassword"
> enable_network 0
> quit

# 3. Verify internet
ping -c 3 nixos.org
```

### Phase 2: Disk Partitioning

```bash
# 1. Identify your disk
lsblk

# 2. Partition with gdisk (for NVMe, usually /dev/nvme0n1)
sudo gdisk /dev/nvme0n1

# Create partitions:
# n, 1, Enter, +512M, EF00    → EFI System Partition
# n, 2, Enter, +8G, 8200      → Swap (optional, we use zram)
# n, 3, Enter, Enter, 8300    → Linux root
# w                           → Write and exit

# 3. Format partitions
sudo mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1
sudo mkswap -L SWAP /dev/nvme0n1p2
sudo mkfs.ext4 -L NIXOS /dev/nvme0n1p3

# 4. Mount filesystems
sudo mount /dev/disk/by-label/NIXOS /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/BOOT /mnt/boot
sudo swapon /dev/disk/by-label/SWAP
```

### Phase 3: Get Configuration

```bash
# 1. Install git
nix-shell -p git

# 2. Clone this repository
git clone https://github.com/cd4u2b0z/nixos-asus-mnemosyne.git /mnt/etc/nixos

# 3. Or copy from USB
cp -r /path/to/usb/nixos-asus-mnemosyne /mnt/etc/nixos
```

### Phase 4: Configure Hardware

```bash
# 1. Generate hardware detection
sudo nixos-generate-config --root /mnt --show-hardware-config > /tmp/hw.nix

# 2. Get your UUIDs
blkid

# Example output:
# /dev/nvme0n1p1: UUID="XXXX-XXXX" TYPE="vfat" PARTLABEL="EFI"
# /dev/nvme0n1p2: UUID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" TYPE="swap"
# /dev/nvme0n1p3: UUID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" TYPE="ext4"

# 3. Edit hardware-configuration.nix
nano /mnt/etc/nixos/hardware-configuration.nix

# Replace these placeholders with your UUIDs:
# - REPLACE-WITH-YOUR-ROOT-UUID
# - REPLACE-WITH-YOUR-BOOT-UUID  
# - REPLACE-WITH-YOUR-SWAP-UUID
```

### Phase 5: Customize Configuration

```bash
# 1. Change username (if not "craig")
nano /mnt/etc/nixos/flake.nix
# Edit: username = "YOUR_USERNAME";

# 2. Set timezone
nano /mnt/etc/nixos/modules/system.nix
# Edit: time.timeZone = "America/New_York";  # Change to your timezone

# 3. Set git credentials
nano /mnt/etc/nixos/home/default.nix
# Edit: userName = "Your Name";
# Edit: userEmail = "your@email.com";
```

### Phase 6: Install NixOS

```bash
# 1. Navigate to config
cd /mnt/etc/nixos

# 2. Stage files for flake (required)
git init
git add -A

# 3. Install NixOS
sudo nixos-install --flake .#mnemosyne

# 4. Set root password when prompted

# 5. Set user password
sudo nixos-enter --root /mnt
passwd craig  # Your username
exit

# 6. Reboot
sudo reboot
```

---

## 🔧 Post-Installation Setup

### First Boot Checklist

After rebooting into your new system:

```bash
# 1. Login at greetd (display manager)
# Enter your username and password

# 2. Hyprland should start automatically with Waybar

# 3. Open terminal: Super + Return

# 4. Verify system
fastfetch  # Shows system info
```

### Initialize Chezmoi (Optional)

If you want to use your existing Chezmoi dotfiles:

```bash
# Initialize Chezmoi
chezmoi init https://github.com/cd4u2b0z/dotfiles.git

# Preview changes
chezmoi diff

# Apply (will overwrite NixOS-managed configs)
chezmoi apply
```

### Set Wallpaper

```bash
# 1. Create wallpaper directory
mkdir -p ~/Pictures/Wallpapers

# 2. Add some wallpapers
# Copy your wallpapers to ~/Pictures/Wallpapers/

# 3. Set wallpaper
swaybg -i ~/Pictures/Wallpapers/your-wallpaper.jpg -m fill &

# 4. Or use the wallpaper picker
~/.config/hyprland/scripts/quick-wallpaper.sh select
```

### 🚀 First Boot Expectations

When you first log into Hyprland, here's what to expect:

| What You'll See | Why | What To Do |
|-----------------|-----|------------|
| **Black/gray background** | No wallpaper set yet | Run `swaybg -i ~/Pictures/Wallpapers/yourimage.jpg -m fill &` or use the wallpaper script |
| **Waybar at top** | Should load automatically | If missing, press `Super+Return` for terminal, then run `waybar &` |
| **No windows open** | Fresh session | Press `Super+Return` for terminal, `Super+R` for app launcher |
| **Mouse cursor works** | Hyprland is running correctly | Good sign! |
| **XWayland apps (Discord) work** | xwayland-satellite starts automatically | If not, run `xwayland-satellite &` |

**First things to verify:**

1. **Open terminal**: `Super + Return` → Kitty should appear
2. **Test launcher**: `Super + R` → Fuzzel should pop up
3. **Check audio**: Click speaker icon in Waybar or run `pactl info`
4. **Test notifications**: Run `notify-send "Test" "Hello World"`
5. **Set wallpaper**: `~/.config/hyprland/scripts/quick-wallpaper.sh select`

> 💡 **Tip**: Your first session may feel bare. After setting a wallpaper and opening a few apps, it will look just like your Hyprland setup!

---

## 🧪 Testing & Validation

Run these tests after installation to ensure everything works:

### Automated Test Script

Save this as `~/test-system.sh` and run it:

```bash
#!/usr/bin/env bash
set -e

echo "═══════════════════════════════════════════════════════════════"
echo "  NixOS + Hyprland Validation Script"
echo "═══════════════════════════════════════════════════════════════"

PASS=0
FAIL=0

test_cmd() {
    if command -v "$1" &>/dev/null; then
        echo "✅ $1 is installed"
        ((PASS++))
    else
        echo "❌ $1 is NOT installed"
        ((FAIL++))
    fi
}

test_service() {
    if systemctl is-active --quiet "$1"; then
        echo "✅ $1 service is running"
        ((PASS++))
    else
        echo "❌ $1 service is NOT running"
        ((FAIL++))
    fi
}

test_file() {
    if [[ -f "$1" ]]; then
        echo "✅ $1 exists"
        ((PASS++))
    else
        echo "❌ $1 is missing"
        ((FAIL++))
    fi
}

echo ""
echo "── Core Applications ──"
test_cmd hyprland
test_cmd waybar
test_cmd kitty
test_cmd fuzzel
test_cmd mako
test_cmd hyprlock
test_cmd grim
test_cmd slurp

echo ""
echo "── Development Tools ──"
test_cmd git
test_cmd nvim
test_cmd code

echo ""
echo "── System Services ──"
test_service NetworkManager
test_service pipewire
test_service bluetooth

echo ""
echo "── Configuration Files ──"
test_file ~/.config/hyprland/hyprland.conf
test_file ~/.config/waybar/config
test_file ~/.config/waybar/style.css
test_file ~/.config/kitty/kitty.conf
test_file ~/.config/mako/config
test_file ~/.config/fuzzel/fuzzel.ini

echo ""
echo "── Hardware Checks ──"
if lspci | grep -i intel &>/dev/null; then
    echo "✅ Intel GPU detected"
    ((PASS++))
else
    echo "⚠️  Intel GPU not detected (may be OK)"
fi

if pactl info &>/dev/null; then
    echo "✅ PipeWire audio working"
    ((PASS++))
else
    echo "❌ Audio not working"
    ((FAIL++))
fi

if ping -c 1 1.1.1.1 &>/dev/null; then
    echo "✅ Network connected"
    ((PASS++))
else
    echo "❌ No network connection"
    ((FAIL++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  Results: $PASS passed, $FAIL failed"
echo "═══════════════════════════════════════════════════════════════"

if [[ $FAIL -eq 0 ]]; then
    echo "🎉 All tests passed! Your system is ready."
else
    echo "⚠️  Some tests failed. Check the items above."
fi
```

Run with:
```bash
chmod +x ~/test-system.sh
~/test-system.sh
```

### Manual Tests

| Test | Command | Expected Result |
|------|---------|-----------------|
| Terminal | `Super + Return` | Kitty opens |
| Launcher | `Super + R` | Fuzzel appears |
| Close Window | `Super + Q` | Window closes |
| Workspaces | `Super + 1-9` | Switch workspace |
| Screenshot | `Super + Shift + S` | Area capture |
| Volume Up | `XF86AudioRaiseVolume` | Volume increases |
| Brightness | `XF86MonBrightnessUp` | Screen brighter |
| Lock Screen | `Super + L` | Hyprlock activates |
| File Manager | `Super + E` | Thunar opens |
| Notifications | `notify-send "Test" "Hello"` | Notification appears |

---

## 🔧 Troubleshooting Guide

### Common Issues & Solutions

#### 1. Black Screen After Login

```bash
# Boot to TTY (Ctrl+Alt+F2)
# Check Hyprland logs
journalctl --user -u hyprland -b

# Common fixes:
# - GPU driver issue: check hardware-configuration.nix
# - Missing config: verify ~/.config/hyprland/hyprland.conf exists
```

#### 2. Waybar Not Showing

```bash
# Start manually to see errors
waybar

# Check for config errors
cat ~/.config/waybar/config | jq .  # Should parse without errors

# Restart Waybar
pkill waybar && waybar &
```

#### 3. No Audio

```bash
# Check PipeWire
systemctl --user status pipewire
systemctl --user status pipewire-pulse

# Restart audio
systemctl --user restart pipewire pipewire-pulse

# Check devices
pactl list sinks short
```

#### 4. WiFi Not Working

```bash
# Check NetworkManager
systemctl status NetworkManager

# List networks
nmcli device wifi list

# Connect
nmcli device wifi connect "SSID" password "PASSWORD"
```

#### 5. Bluetooth Not Connecting

```bash
# Check Bluetooth service
systemctl status bluetooth

# Start if not running
sudo systemctl start bluetooth

# Use bluetoothctl to pair
bluetoothctl
> power on
> agent on
> default-agent
> scan on
# Wait for your device to appear (e.g., [NEW] Device XX:XX:XX:XX:XX:XX Your Device)
> pair XX:XX:XX:XX:XX:XX
> trust XX:XX:XX:XX:XX:XX
> connect XX:XX:XX:XX:XX:XX
> quit

# For GUI management
blueman-manager
```

**Common Bluetooth Issues:**

| Issue | Solution |
|-------|----------|
| Device not found | Ensure device is in pairing mode, run `scan on` |
| Connection refused | Remove and re-pair: `remove XX:XX:XX:XX:XX:XX` then pair again |
| Audio device no sound | Check PipeWire: `pactl list sinks short`, select Bluetooth sink |
| Bluetooth disabled after reboot | Check BIOS settings, ensure `hardware.bluetooth.enable = true` |

#### 6. Keybindings Not Working

```bash
# Verify Hyprland config syntax
hyprland validate

# Check if Hyprland is reading config
hyprland msg outputs  # Should respond

# Reload config
hyprland msg action reload-config
```

#### 7. Flake Build Errors

```bash
# Update flake lock
nix flake update

# Check for syntax errors
nix flake check

# Build without switching (dry run)
nixos-rebuild build --flake .#mnemosyne

# View build logs
nixos-rebuild switch --flake .#mnemosyne 2>&1 | tee /tmp/build.log
```

#### 8. Missing Fonts/Icons

```bash
# Rebuild font cache
fc-cache -fv

# Verify fonts installed
fc-list | grep -i "JetBrains"
fc-list | grep -i "Inter"

# Check icon theme
ls /run/current-system/sw/share/icons/
```

### Debug Mode Boot

If system won't boot:

1. At GRUB menu, select previous generation
2. Or select "NixOS - Configuration X (recovery)"
3. Once booted, fix configuration and rebuild

---

## 📖 Daily Usage Commands

### System Updates

```bash
# Update flake inputs
cd /etc/nixos
sudo nix flake update

# Rebuild system
sudo nixos-rebuild switch --flake .#mnemosyne

# Or test first (doesn't persist after reboot)
sudo nixos-rebuild test --flake .#mnemosyne
```

### Package Management

```bash
# Search for packages
nix search nixpkgs firefox

# Try a package temporarily
nix-shell -p package-name

# Run without installing
nix run nixpkgs#cowsay -- "Hello"
```

### Garbage Collection

```bash
# Remove old generations (keep last 5)
sudo nix-collect-garbage --delete-older-than 7d

# Remove ALL old generations (careful!)
sudo nix-collect-garbage -d

# Optimize store
sudo nix-store --optimize
```

### Configuration Changes

```bash
# Edit configuration
sudo nano /etc/nixos/modules/packages.nix

# Rebuild and switch
sudo nixos-rebuild switch --flake /etc/nixos#mnemosyne

# Rebuild home-manager only
home-manager switch --flake /etc/nixos#craig@mnemosyne
```

---

## ⌨️ Keybindings Reference

### Window Management

| Keybinding | Action |
|------------|--------|
| `Super + Q` | Close window |
| `Super + Return` | Open terminal (Kitty) |
| `Super + R` | Open launcher (Fuzzel) |
| `Super + E` | Open file manager (Thunar) |
| `Super + B` | Open browser (Firefox) |
| `Super + L` | Lock screen |

### Navigation

| Keybinding | Action |
|------------|--------|
| `Super + H/J/K/L` | Focus left/down/up/right |
| `Super + 1-9` | Switch to workspace |
| `Super + Shift + 1-9` | Move window to workspace |
| `Super + Tab` | Focus next window |

### Window Movement

| Keybinding | Action |
|------------|--------|
| `Super + Shift + H/L` | Move column left/right |
| `Super + Ctrl + H/J/K/L` | Move window in column |
| `Super + Minus` | Decrease column width |
| `Super + Equal` | Increase column width |
| `Super + F` | Toggle fullscreen |
| `Super + Shift + F` | Toggle floating |

### Media & System

| Keybinding | Action |
|------------|--------|
| `XF86AudioRaiseVolume` | Volume up |
| `XF86AudioLowerVolume` | Volume down |
| `XF86AudioMute` | Toggle mute |
| `XF86MonBrightnessUp` | Brightness up |
| `XF86MonBrightnessDown` | Brightness down |
| `Super + Shift + S` | Screenshot area |
| `Print` | Screenshot full screen |

### Session

| Keybinding | Action |
|------------|--------|
| `Super + Shift + E` | Exit Hyprland |
| `Super + Shift + R` | Reload config |

---

## 🎨 Customization

### Change Wallpaper

```bash
# Set static wallpaper
swaybg -i /path/to/wallpaper.jpg -m fill &

# Use wallpaper picker
~/.config/hyprland/scripts/quick-wallpaper.sh select

# Set random wallpaper
~/.config/hyprland/scripts/quick-wallpaper.sh random
```

### Change Theme Colors

Edit `~/.config/waybar/wallust-colors.css`:

```css
@define-color background #2e3440;
@define-color foreground #eceff4;
@define-color accent #5e81ac;
/* ... etc */
```

### Add New Packages

Edit `/etc/nixos/modules/packages.nix`:

```nix
environment.systemPackages = with pkgs; [
  # Add your packages here
  spotify
  discord
  slack
];
```

Then rebuild:

```bash
sudo nixos-rebuild switch --flake /etc/nixos#mnemosyne
```

### Modify Keybindings

Edit `~/.config/hyprland/hyprland.conf` or `/etc/nixos/home/dotfiles/hyprland/hyprland.conf`:

```kdl
binds {
    // Add your custom bindings
    Mod+P { spawn "pavucontrol"; }
}
```

---

## 🔄 Rollback & Recovery

### List Generations

```bash
# System generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Home Manager generations
home-manager generations
```

### Rollback System

```bash
# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Or at boot: select older generation from GRUB menu
```

### Rollback Home Manager

```bash
# List generations
home-manager generations

# Activate specific generation
/nix/var/nix/profiles/per-user/craig/home-manager-XXX-link/activate
```

### Emergency Recovery

If system is unbootable:

1. Boot from NixOS USB
2. Mount your partitions:
   ```bash
   sudo mount /dev/disk/by-label/NIXOS /mnt
   sudo mount /dev/disk/by-label/BOOT /mnt/boot
   ```
3. Chroot and fix:
   ```bash
   sudo nixos-enter --root /mnt
   cd /etc/nixos
   # Fix configuration
   nixos-rebuild switch --flake .#mnemosyne
   ```

---

## 📚 Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Hyprland Documentation](https://github.com/YaLTeR/hyprland/wiki)
- [Nix Package Search](https://search.nixos.org/packages)
- [NixOS Discourse](https://discourse.nixos.org/)

---

## 🤝 Credits

- Configuration translated from Arch Linux + Hyprland setup
- Dotfiles managed with Chezmoi: `https://github.com/cd4u2b0z/dotfiles.git`
- Theme: Nord color scheme

---

**Happy computing! 🚀**
