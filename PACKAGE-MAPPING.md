# Ansible vs NixOS Package Mapping

This document shows how your Arch packages were translated to NixOS.

## System Packages (from ansible-system/roles/packages)

| Arch Package | NixOS Package | Status |
|--------------|---------------|---------|
| zsh | zsh | ✅ |
| starship | starship | ✅ |
| kitty | kitty | ✅ |
| neovim | neovim | ✅ |
| bat | bat | ✅ |
| eza | eza | ✅ |
| fd | fd | ✅ |
| ripgrep | ripgrep | ✅ |
| fzf | fzf | ✅ |
| btop | btop | ✅ |
| fastfetch | fastfetch | ✅ |
| thunar | thunar | ✅ |
| unzip | unzip | ✅ |
| zip | zip | ✅ |
| p7zip | p7zip | ✅ |
| git | git | ✅ |
| gcc | gcc | ✅ |
| python3 | python3 | ✅ |
| nodejs | nodejs | ✅ |
| firefox | firefox | ✅ | (Wayland via MOZ_ENABLE_WAYLAND=1)
| steam | steam | ✅ |
| lutris | lutris | ✅ |
| wine | wine | ✅ |
| mangohud | mangohud | ✅ |
| gamemode | gamemode | ✅ |
| pipewire | pipewire | ✅ |
| wireplumber | wireplumber | ✅ |
| pavucontrol | pavucontrol | ✅ |
| mpd | mpd | ✅ |
| mpv | mpv | ✅ |
| vlc | vlc | ✅ |
| obs-studio | obs-studio | ✅ |
| networkmanager | networkmanager | ✅ |
| gparted | gparted | ✅ |
| libreoffice | libreoffice | ✅ |
| discord | discord | ✅ |
| telegram-desktop | telegram-desktop | ✅ |

## AUR Packages (from ansible-system/roles/aur)

| AUR Package | NixOS Equivalent | Status |
|-------------|------------------|---------|
| brave-bin | brave | ✅ |
| librewolf-bin | librewolf | ✅ |
| visual-studio-code-bin | vscode | ✅ |
| paru | N/A (nix handles this) | ⚠️ Not needed |
| yay | N/A (nix handles this) | ⚠️ Not needed |
| oh-my-zsh-git | oh-my-zsh | ✅ |
| arc-gtk-theme | arc-theme | ✅ |
| nordic-theme | nordic | ✅ |
| nordzy-cursors | nordzy-cursor-theme | ✅ |
| papirus-folders | papirus-icon-theme | ✅ |
| waybar-updates | waybar | ✅ (integrated) |
| heroic-games-launcher | heroic | ✅ |
| bottles | bottles | ✅ |
| protonup-qt-bin | protonup-qt | ✅ |
| ryujinx | ryubing | ✅ | (community fork, ryujinx discontinued)
| wallust | wallust | ✅ | (available in nixpkgs unstable)
| cmatrix-git | cmatrix | ✅ |
| pipes.sh | pipes | ✅ |
| cbonsai-git | cbonsai | ✅ | (available in nixpkgs unstable)
| dxvk-bin | dxvk | ✅ |
| vkd3d-proton-bin | vkd3d-proton | ✅ |
| faudio | faudio | ✅ |
| lib32-faudio | faudio (32-bit) | ✅ |
| python-asciimatics | python311Packages.asciimatics | ✅ |

## Wayland Ecosystem (Hyprland → Niri)

| Component | Hyprland Setup | Niri Setup | Status |
|-----------|----------------|------------|---------|
| Compositor | hyprland | niri | ✅ Replaced |
| Status bar | waybar | waybar | ✅ Same |
| Notifications | mako | mako | ✅ Same |
| Launcher | fuzzel | fuzzel | ✅ Same |
| Locker | hyprlock | swaylock-effects | ✅ Alternative |
| Idle | hypridle | swayidle | ✅ Alternative |
| Screenshots | grim + slurp | grim + slurp | ✅ Same |
| Clipboard | wl-clipboard | wl-clipboard | ✅ Same |
| Wallpaper | hyprpaper | swaybg | ✅ Alternative |

## Services (systemd)

| Service | Ansible Setup | NixOS Setup | Status |
|---------|---------------|-------------|---------|
| NetworkManager | enabled | enabled | ✅ |
| bluetooth | enabled | enabled | ✅ |
| pipewire | user service | user service | ✅ |
| wireplumber | user service | user service | ✅ |
| mpd | user service | user service | ✅ |
| cronie | system timer | nix cron | ✅ |
| reflector.timer | system timer | not needed | ⚠️ NixOS doesn't need mirrorlist updates |
| hypridle | user service | swayidle (user) | ✅ Alternative |

## System Configuration

| Setting | Ansible | NixOS | Status |
|---------|---------|--------|---------|
| User management | ansible user creation | users.users.craig | ✅ |
| Dotfiles | chezmoi | home-manager + chezmoi | ✅ Hybrid |
| Package management | pacman + paru | nix | ✅ |
| System updates | manual | nixos-rebuild | ✅ |
| Rollbacks | timeshift/snapshots | nix generations | ✅ Better |
| Reproducibility | ansible playbook | flake.nix | ✅ Better |

## Configuration Files

| File Type | Ansible Location | NixOS Location | Approach |
|-----------|-----------------|----------------|-----------|
| Waybar | chezmoi | Symlink from chezmoi | ✅ Reuse |
| Kitty | chezmoi | Symlink from chezmoi | ✅ Reuse |
| Neovim | chezmoi | Symlink from chezmoi | ✅ Reuse |
| Zsh | chezmoi | Symlink from chezmoi | ✅ Reuse |
| Hyprland | chezmoi | Replaced with Niri | ✅ New config |
| Mako | chezmoi | Symlink from chezmoi | ✅ Reuse |
| Fuzzel | chezmoi | Symlink from chezmoi | ✅ Reuse |
| MPD | chezmoi | Symlink from chezmoi | ✅ Reuse |

## What Changes from Your Workflow

### ❌ No Longer Needed:
- `paru` or `yay` (AUR helpers)
- `ansible-playbook` runs
- Manual package installation
- Pacman mirrorlist updates
- Manual service enabling/disabling

### ✅ New Tools:
- `nixos-rebuild` (system updates)
- `nix flake update` (update package sources)
- `nix-collect-garbage` (cleanup)
- Home Manager for user config
- `niri` instead of `hyprland`

### 🔄 Stays The Same:
- `chezmoi` for dotfiles
- All your config files (except Hyprland)
- Terminal workflows (zsh, tmux, etc.)
- Development tools
- Gaming setup

## Performance Comparison

| Aspect | Arch + Hyprland | NixOS + Niri |
|--------|----------------|--------------|
| Boot time | ~5-10s | ~5-10s (similar) |
| Memory usage | Low | Low (similar) |
| Update speed | Fast (pacman) | Slower (downloads more) |
| Disk usage | Smaller | Larger (keeps old generations) |
| System stability | Very stable | Very stable |
| Rollback capability | Manual snapshots | Built-in (instant) |
| Reproducibility | Requires Ansible run | Instant (nix copy) |

## Gaming Performance

No change expected! Both setups use:
- Same kernel
- Same GPU drivers (AMD)
- Same Wayland protocol
- Same gaming tools (Steam, GameMode, MangoHud)
- Same Proton/Wine

Niri may actually be slightly better for gaming due to:
- Simpler compositor (fewer animations)
- Better window management for multiple monitors
- Less resource usage than Hyprland

## Migration Checklist

- [ ] Backup current Arch system
- [ ] Clone this NixOS config
- [ ] Test in VM (optional)
- [ ] Install NixOS on ASUS Vivobook
- [ ] Apply Chezmoi dotfiles
- [ ] Test Niri keybindings
- [ ] Verify all apps work
- [ ] Set up game libraries
- [ ] Import SSH/GPG keys
- [ ] Configure Git credentials
- [ ] Test gaming performance

## Troubleshooting Common Issues

### "Package not found"
Some AUR packages might not be in nixpkgs. Options:
1. Search nixpkgs: `nix search nixpkgs <package>`
2. Build from source using a nix derivation
3. Use alternatives from nixpkgs

### "Missing dependency"
NixOS handles all dependencies automatically. If something's missing:
1. Check if it's in `environment.systemPackages`
2. Check if you need to enable a program module
3. May need to add to `home.packages` instead

### "Service won't start"
NixOS uses declarative services:
1. Check if service is enabled in `modules/services.nix`
2. Check logs: `journalctl -u service-name`
3. May need to enable in Home Manager instead

## Resources for Learning More

- **Nix Pills**: https://nixos.org/guides/nix-pills/
- **NixOS Manual**: https://nixos.org/manual/nixos/stable/
- **Home Manager**: https://nix-community.github.io/home-manager/
- **Niri Wiki**: https://github.com/YaLTeR/niri/wiki
- **NixOS Discourse**: https://discourse.nixos.org/

---

**Summary**: 95% of your packages have direct NixOS equivalents. The main change is switching from Hyprland to Niri, but all your other configs and workflows remain the same!
