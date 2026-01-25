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
| firefox | firefox | ✅ (Wayland via MOZ_ENABLE_WAYLAND=1) |
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
| wallust | wallust | ✅ (available in nixpkgs unstable) |
| cmatrix-git | cmatrix | ✅ |
| pipes.sh | pipes | ✅ |

## Wayland Ecosystem (Hyprland - identical to Arch)

| Component | Arch Setup | NixOS Setup | Status |
|-----------|------------|-------------|---------|
| Compositor | hyprland | hyprland | ✅ Same |
| Status bar | waybar | waybar | ✅ Same |
| Notifications | mako | mako | ✅ Same |
| Launcher | fuzzel | fuzzel | ✅ Same |
| Locker | hyprlock | hyprlock | ✅ Same |
| Idle | hypridle | hypridle | ✅ Same |
| Wallpaper | hyprpaper | hyprpaper | ✅ Same |
| Screenshots | grim + slurp | grim + slurp | ✅ Same |
| Clipboard | wl-clipboard | wl-clipboard | ✅ Same |
| Color picker | hyprpicker | hyprpicker | ✅ Same |

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
| hypridle | user service | user service | ✅ |

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
| Hyprland | chezmoi | home/dotfiles/hypr/ | ✅ Bundled |
| Waybar | chezmoi | home/dotfiles/waybar/ | ✅ Bundled |
| Kitty | chezmoi | home/dotfiles/kitty/ | ✅ Bundled |
| Mako | chezmoi | home/dotfiles/mako/ | ✅ Bundled |
| Fuzzel | chezmoi | home/dotfiles/fuzzel/ | ✅ Bundled |
| Neovim | chezmoi | Symlink from chezmoi | ✅ Reuse |
| Zsh | chezmoi | Managed by Home Manager | ✅ Bundled |
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

### 🔄 Stays The Same:
- Hyprland compositor
- All your config files (hyprland.conf, hyprlock.conf, etc.)
- Terminal workflows (zsh, tmux, etc.)
- Development tools
- `chezmoi` for additional dotfiles

## Performance Comparison

| Aspect | Arch + Hyprland | NixOS + Hyprland |
|--------|----------------|------------------|
| Boot time | ~5-10s | ~5-10s (similar) |
| Memory usage | Low | Low (similar) |
| Update speed | Fast (pacman) | Slower (downloads more) |
| Disk usage | Smaller | Larger (keeps old generations) |
| System stability | Very stable | Very stable |
| Rollback capability | Manual snapshots | Built-in (instant) |
| Reproducibility | Requires Ansible run | Instant (nix copy) |

## Migration Checklist

- [ ] Backup current Arch system
- [ ] Clone this NixOS config
- [ ] Test in VM (optional)
- [ ] Install NixOS on ASUS Vivobook
- [ ] Update hardware-configuration.nix with actual UUIDs
- [ ] Apply Chezmoi dotfiles
- [ ] Test Hyprland keybindings
- [ ] Verify all apps work
- [ ] Import SSH/GPG keys
- [ ] Configure Git credentials

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
- **Hyprland Wiki**: https://wiki.hyprland.org/
- **NixOS Discourse**: https://discourse.nixos.org/

---

**Summary**: 95% of your packages have direct NixOS equivalents. This is essentially the same Arch + Hyprland setup, just managed declaratively with NixOS instead of Ansible/pacman.
