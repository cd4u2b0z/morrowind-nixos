# Quick Start Guide - NixOS with Hyprland

## What You Got

I've created a complete NixOS flake configuration for your ASUS Vivobook S15 that:

✅ **Replaces Hyprland with Hyprland** - A modern scrollable-tiling Wayland compositor  
✅ **Preserves your ecosystem** - Waybar, Mako, Fuzzel, Kitty all work the same  
✅ **Keeps your Chezmoi dotfiles** - Integrated via Home Manager symlinks  
✅ **Intel optimized** - TLP, thermald, Intel UHD 620 drivers  
✅ **Fully modular** - Each component in separate flake modules  

## Key Differences from Your Arch Setup

| Arch + Ansible | NixOS Flakes |
|----------------|--------------|
| Pacman/AUR packages | Nix packages (all in one repository) |
| Hyprland | **Hyprland** (scrollable tiling instead of dynamic tiling) |
| Ansible roles | Flake modules |
| Chezmoi applies dotfiles | Home Manager + Chezmoi (hybrid approach) |
| Manual service management | Declarative systemd services |
| System state changes | Atomic upgrades & rollbacks |

## Hyprland vs Hyprland

### What's Different:
- **Tiling model**: Hyprland uses horizontal scrollable columns, not dynamic tiling
- **Config format**: KDL format (`.kdl`) instead of Hyprland's format
- **Navigation**: Scroll through workspaces like a timeline
- **Gestures**: Built-in touchpad gestures for laptop use

### What's The Same:
- All the same Wayland tools work (Waybar, Mako, Fuzzel, etc.)
- Same keybindings (I translated them for you)
- Same performance benefits

## Installation Steps (Summary)

1. **Boot NixOS ISO** on ASUS Vivobook S15
2. **Partition disk** (EFI + Swap + Root)
3. **Mount and generate config**: `nixos-generate-config --root /mnt`
4. **Clone this repo** to `/mnt/home/nixos-asus-mnemosyne`
5. **Edit UUIDs** in `hardware-configuration.nix`
6. **Install**: `sudo nixos-install --flake .#mnemosyne`
7. **Set password** and reboot
8. **Apply Chezmoi** dotfiles: `chezmoi init && chezmoi apply`
9. **Enjoy!**

Full details in [README.md](README.md)

## Project Structure

```
nixos-asus-mnemosyne/
├── flake.nix                 # Main entry point, defines inputs/outputs
├── hardware-configuration.nix # ASUS Vivobook specific hardware
├── modules/
│   ├── system.nix           # Users, locale, timezone, Nix settings
│   ├── hyprland.nix             # Hyprland compositor + Wayland environment
│   ├── packages.nix         # All your Arch packages translated
│   └── services.nix         # NetworkManager, Bluetooth, Audio, etc.
└── home/
    ├── default.nix          # Home Manager user config
    └── dotfiles/
        └── hyprland/
            └── hyprland.conf   # Hyprland keybindings (translated from Hyprland)
```

## Daily Usage

### Rebuild after changes:
```bash
cd ~/projects/nixos-asus-mnemosyne
sudo nixos-rebuild switch --flake .#mnemosyne
```

### Update packages:
```bash
nix flake update
sudo nixos-rebuild switch --flake .#mnemosyne
```

### Rollback if something breaks:
```bash
sudo nixos-rebuild switch --rollback
```

## What You Need To Do

### During Installation:
1. ⚠️ **Replace UUIDs** in `hardware-configuration.nix` with your partition UUIDs
2. ⚠️ **Set timezone** in `modules/system.nix`
3. ⚠️ **Set Git name/email** in `home/default.nix`

### After First Boot:
1. Initialize Chezmoi: `chezmoi init https://github.com/cd4u2b0z/dotfiles.git`
2. Apply dotfiles: `chezmoi apply`
3. Customize Hyprland config at `~/.config/hyprland/hyprland.conf`
4. Test keybindings (they're the same as your Hyprland setup!)

## Keybindings (Same as Hyprland)

- `Super + Return` → Kitty terminal
- `Super + D` → Fuzzel launcher
- `Super + Q` → Close window
- `Super + E` → Thunar file manager
- `Super + 1-9` → Switch workspace
- `Super + Shift + 1-9` → Move window to workspace
- `Super + H/J/K/L` → Navigate windows (Vim-style)
- `Print` → Screenshot region
- `Super + Print` → Screenshot full screen

See [home/dotfiles/hyprland/hyprland.conf](home/dotfiles/hyprland/hyprland.conf) for all keybindings.

## Customization Tips

### Add a package:
Edit `modules/packages.nix`:
```nix
environment.systemPackages = with pkgs; [
  # Add your package here
  htop
];
```

### Change Hyprland settings:
Edit `~/.config/hyprland/hyprland.conf` after installation

### Adjust Waybar:
Your existing Waybar config works! Just update modules:
```json
{
    "modules-left": ["hyprland/workspaces", "hyprland/window"],
    // ...
}
```

## Advantages of This Setup

1. **Reproducible** - Reinstall on any machine with same config
2. **Atomic updates** - Updates are all-or-nothing, no half-broken state
3. **Rollback** - Every generation is bootable from GRUB
4. **Declarative** - Entire system in version control
5. **Hyprland benefits** - Better for laptops, smooth scrolling, touchpad gestures
6. **Keeps Chezmoi** - Your dotfiles work exactly as before

## Testing Before Installing

Want to try in a VM first?

```bash
# On your current Arch system
cd ~/projects/nixos-asus-mnemosyne
nix run .#mnemosyne.config.system.build.vm
```

## Need Help?

- 📖 Full guide: [README.md](README.md)
- 🐛 Troubleshooting section in README
- 🔍 Hyprland docs: https://github.com/YaLTeR/hyprland/wiki
- 💬 NixOS discourse: https://discourse.nixos.org/

## Backing Out

If you decide NixOS isn't for you:
- Just boot back into your Arch install (if you kept it)
- Or reinstall Arch - your Chezmoi dotfiles work anywhere!

---

**You're all set!** This configuration should work out of the box on your ASUS Vivobook S15. 🚀
