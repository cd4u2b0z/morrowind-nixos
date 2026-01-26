# 🔄 Arch Linux vs NixOS: A Complete Migration Guide

If you're coming from Arch Linux, NixOS will feel **very different**. This document explains the mental shift required and provides practical examples for common tasks.

## The Fundamental Difference

| Aspect | Arch Linux | NixOS |
|--------|------------|-------|
| **Config location** | `~/.config/`, `/etc/` | `~/nixos-config/` (source of truth) |
| **How changes work** | Edit file → done | Edit nix file → rebuild → done |
| **Persistence** | Direct edits persist | Direct edits get **overwritten** on rebuild |
| **Rollback** | Manual/Timeshift | Built-in generations |
| **Package install** | `pacman -S pkg` | Add to `packages.nix` → rebuild |
| **Config management** | Manual or dotfile manager | Declarative in Nix |

## ⚠️ THE GOLDEN RULE

> **NEVER edit files in `~/.config/` directly on NixOS if they are managed by Home Manager!**
> 
> Your changes WILL be lost on the next `nixos-rebuild switch`.

Instead, edit the **source files** in your NixOS config repo, then rebuild.

---


---

## 🎨 Theming: Wallust vs Stylix

This is one of the **biggest differences** between Arch and NixOS Hyprland setups.

### On Arch Linux (with Wallust)
- **Runtime theming**: Press `Super+W` → pick theme → colors change instantly
- Wallust extracts colors from wallpaper or uses preset themes
- Writes to config files directly (`~/.config/kitty/wallust-colors.conf`, etc.)
- Apps source these files and reload on-the-fly

### On NixOS (with Stylix)
- **Build-time theming**: Edit config → rebuild → colors applied
- Stylix uses base16 color schemes (same palette format, 200+ themes)
- Generates themed configs during `nixos-rebuild`
- All apps themed consistently from ONE source of truth

### Why Can't We Use Wallust on NixOS?

Home Manager creates **read-only symlinks** to the Nix store. Wallust can't write to:
- `~/.config/kitty/kitty.conf` → symlink to `/nix/store/...`
- `~/.config/waybar/style.css` → symlink to `/nix/store/...`

Wallust's runtime approach fundamentally conflicts with NixOS's declarative model.

### Stylix Workflow

```bash
# 1. Edit modules/stylix.nix
nvim ~/nixos-config/modules/stylix.nix

# Change this line:
base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
# To:
base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

# 2. Rebuild (~30 seconds)
sudo nixos-rebuild switch --flake ~/nixos-config#mnemosyne

# 3. Done! Everything is themed:
#    - Kitty terminal colors
#    - Waybar colors
#    - Mako notification colors
#    - Fuzzel launcher colors
#    - Hyprland border colors
#    - GTK theme
#    - Neovim colorscheme
#    - Cursor theme
```

### Popular Themes (Same Names as Wallust!)

| Theme | Stylix Path |
|-------|-------------|
| Nord | `nord.yaml` |
| Gruvbox Dark | `gruvbox-dark-hard.yaml` |
| Catppuccin Mocha | `catppuccin-mocha.yaml` |
| Dracula | `dracula.yaml` |
| Tokyo Night | `tokyo-night-dark.yaml` |
| Everforest | `everforest.yaml` |
| Rosé Pine | `rose-pine.yaml` |
| Solarized Dark | `solarized-dark.yaml` |
| One Dark | `onedark.yaml` |

### What About Wallpaper-Based Theming?

Stylix can also extract colors from your wallpaper (like `wallust run`):

```nix
# In modules/stylix.nix, comment out base16Scheme and just use:
stylix = {
  enable = true;
  image = ./wallpapers/your-wallpaper.jpg;
  # No base16Scheme = colors extracted from wallpaper!
};
```

### The Trade-off

| | Arch + Wallust | NixOS + Stylix |
|---|----------------|----------------|
| **Speed** | Instant | ~30 sec rebuild |
| **Persistence** | Need scripts to persist | Always consistent |
| **Reproducibility** | Manual | Fully declarative |
| **Live switching** | ✅ Super+W | ❌ Must rebuild |
| **Git-trackable** | Partial | ✅ Everything |

**Bottom line**: You lose live theme switching, but gain a reproducible, version-controlled rice that works identically on any machine.

## 📁 Where to Edit Things

Here is the mapping for this configuration:

| What you want to edit | Arch Linux location | NixOS location (edit here!) |
|-----------------------|--------------------|-----------------------------|
| Hyprland config | `~/.config/hypr/hyprland.conf` | `~/nixos-config/home/dotfiles/hypr/hyprland.conf` |
| Hyprlock config | `~/.config/hypr/hyprlock.conf` | `~/nixos-config/home/dotfiles/hypr/hyprlock.conf` |
| Waybar config | `~/.config/waybar/config` | `~/nixos-config/home/dotfiles/waybar/config` |
| Waybar style | `~/.config/waybar/style.css` | `~/nixos-config/home/dotfiles/waybar/style.css` |
| Kitty terminal | `~/.config/kitty/kitty.conf` | `~/nixos-config/home/dotfiles/kitty/kitty.conf` |
| Starship prompt | `~/.config/starship.toml` | `~/nixos-config/home/dotfiles/starship.toml` |
| Mako notifications | `~/.config/mako/config` | `~/nixos-config/home/dotfiles/mako/config` |
| Fuzzel launcher | `~/.config/fuzzel/fuzzel.ini` | `~/nixos-config/home/dotfiles/fuzzel/fuzzel.ini` |
| Neovim config | `~/.config/nvim/` | `~/nixos-config/home/dotfiles/nvim/` |
| Theme (Stylix) | `N/A (wallust was runtime)` | `~/nixos-config/modules/stylix.nix` |
| Zsh aliases | `~/.zshrc` | `~/nixos-config/home/default.nix` (shellAliases section) |
| Zsh config | `~/.zshrc` | `~/nixos-config/home/default.nix` (programs.zsh section) |
| Custom scripts | `~/.local/bin/` | `~/nixos-config/home/dotfiles/bin/` |
| System packages | `pacman -S` | `~/nixos-config/modules/packages.nix` |
| System services | `systemctl enable` | `~/nixos-config/modules/services.nix` |

---

## 🔧 Common Tasks: Arch vs NixOS

### Adding a Shell Alias

**Arch Linux:**
```bash
# Edit ~/.zshrc
echo 'alias ll="ls -la"' >> ~/.zshrc
source ~/.zshrc
# Done!
```

**NixOS:**
```bash
# 1. Edit the nix config
cd ~/nixos-config
nvim home/default.nix

# 2. Find the shellAliases section and add:
#    shellAliases = {
#      ll = "ls -la";  # <-- Add here
#    };

# 3. Rebuild
sudo nixos-rebuild switch --flake .#mnemosyne

# 4. Open new terminal (or source)
```

### Changing a Hyprland Keybinding

**Arch Linux:**
```bash
nvim ~/.config/hypr/hyprland.conf
# Edit the bind, save
# Reload with Super+Shift+R or hyprctl reload
```

**NixOS:**
```bash
# 1. Edit the SOURCE file
cd ~/nixos-config
nvim home/dotfiles/hypr/hyprland.conf

# 2. Rebuild to apply
sudo nixos-rebuild switch --flake .#mnemosyne

# 3. Hyprland will use the new config
# Or reload with hyprctl reload
```

### Installing a Package

**Arch Linux:**
```bash
sudo pacman -S firefox
# Done! Run firefox
```

**NixOS:**
```bash
# 1. Edit packages.nix
cd ~/nixos-config
nvim modules/packages.nix

# 2. Add to environment.systemPackages:
#    environment.systemPackages = with pkgs; [
#      firefox  # <-- Add here
#    ];

# 3. Rebuild
sudo nixos-rebuild switch --flake .#mnemosyne

# Now firefox is installed
```

**NixOS (temporary/testing):**
```bash
# For quick testing without permanent install:
nix-shell -p firefox
# firefox is available in this shell only
```

### Adding a Custom Script

**Arch Linux:**
```bash
# Create script
nvim ~/.local/bin/my-script
chmod +x ~/.local/bin/my-script
# Done! Run my-script
```

**NixOS:**
```bash
# 1. Create script in your config repo
cd ~/nixos-config
nvim home/dotfiles/bin/my-script

# 2. Make sure it is included in home/default.nix:
#    home.file.".local/bin" = {
#      source = ./dotfiles/bin;
#      recursive = true;
#      executable = true;
#    };

# 3. Rebuild
sudo nixos-rebuild switch --flake .#mnemosyne

# Script is now at ~/.local/bin/my-script
```

### Enabling a System Service

**Arch Linux:**
```bash
sudo systemctl enable --now bluetooth
# Done!
```

**NixOS:**
```bash
# 1. Edit services.nix
cd ~/nixos-config
nvim modules/services.nix

# 2. Add:
#    services.bluetooth.enable = true;

# 3. Rebuild
sudo nixos-rebuild switch --flake .#mnemosyne
# Service is now enabled and running
```

---

## 🚀 Quick Edit Workflow

For rapid iteration while tweaking configs, use this workflow:

```bash
# Terminal 1: Edit your config
cd ~/nixos-config
nvim home/dotfiles/hypr/hyprland.conf  # or whatever

# Terminal 2: Rebuild loop
cd ~/nixos-config
sudo nixos-rebuild switch --flake .#mnemosyne && hyprctl reload
```

### Pro Tips for Faster Iteration

1. **Use Home Manager switch for dotfile-only changes:**
   ```bash
   home-manager switch --flake .#craig@mnemosyne
   ```
   This is faster than full system rebuild when you only changed dotfiles.

2. **Test hyprland changes without rebuild:**
   ```bash
   # Copy directly for testing (will be overwritten on rebuild)
   cp home/dotfiles/hypr/hyprland.conf ~/.config/hypr/hyprland.conf
   hyprctl reload
   # If it works, then do the proper rebuild
   ```

3. **Use nix-shell for temporary packages:**
   ```bash
   # Need imagemagick for one command?
   nix-shell -p imagemagick --run "convert input.png output.jpg"
   ```

4. **Git commit before rebuild:**
   ```bash
   git add -A && git commit -m "WIP: testing waybar change"
   sudo nixos-rebuild switch --flake .#mnemosyne
   # If it breaks, you can revert
   ```

---

## 🧠 Mental Model Shift

### Arch Mindset (Imperative)
> "I want firefox. I will install it now."
> 
> "I want this alias. I will add it to .zshrc."
> 
> "Config looks wrong. I will edit it directly."

### NixOS Mindset (Declarative)
> "My system SHOULD have firefox. I will declare it in my config."
> 
> "My shell SHOULD have this alias. I will declare it in home.nix."
> 
> "Config looks wrong. I will fix the source and rebuild."

The key insight: **In NixOS, your config repo IS your system.** The files in `~/.config/` are just **generated outputs** from your Nix declarations.

---

## 🗂️ File Ownership in This Config

Understanding what is managed by Nix vs what you can edit freely:

### Managed by Home Manager (DO NOT edit directly)
These files are **symlinked** or **copied** from your nixos-config on every rebuild:
- `~/.config/hypr/*`
- `~/.config/waybar/*`
- `~/.config/kitty/*`
- `~/.config/mako/*`
- `~/.config/fuzzel/*`
- `~/.config/nvim/*`
- `~/.config/starship.toml`
# Note: Theme colors now generated by Stylix, not from dotfiles
- `~/.config/cava/*`
- `~/.local/bin/*` (scripts)
- `~/.zshrc` (generated from programs.zsh in home.nix)

### NOT managed (safe to edit directly)
These are created by applications at runtime:
- `~/.cache/*` - Cache files
- `~/.local/share/*` - Application data
- `~/Pictures/*` - Your wallpapers
- `~/Documents/*`, `~/Downloads/*` - Your files
- `~/.zshrc.local` - Machine-specific zsh config (sourced by main .zshrc)

---

## 🔍 How to Check if a File is Managed

```bash
# Check if a file is a symlink (managed by Home Manager)
ls -la ~/.config/hypr/hyprland.conf
# If it shows: hyprland.conf -> /nix/store/xxx-home-manager-files/.config/hypr/hyprland.conf
# Then it is managed! Edit the source in ~/nixos-config instead.

# Check the actual source
readlink -f ~/.config/hypr/hyprland.conf
```

---

## 📝 Adding New Dotfiles to Home Manager

Want to manage a new application config with NixOS? Here is how:

### Step 1: Create the config file
```bash
cd ~/nixos-config
mkdir -p home/dotfiles/newapp
nvim home/dotfiles/newapp/config
```

### Step 2: Tell Home Manager about it
Edit `home/default.nix`:
```nix
# Add this line
xdg.configFile."newapp/config".source = ./dotfiles/newapp/config;
```

### Step 3: Rebuild
```bash
sudo nixos-rebuild switch --flake .#mnemosyne
```

Now `~/.config/newapp/config` will be managed by NixOS!

### For Directories with Multiple Files
```nix
xdg.configFile."newapp" = {
  source = ./dotfiles/newapp;
  recursive = true;
};
```

### For Executable Scripts
```nix
xdg.configFile."newapp/script.sh" = {
  source = ./dotfiles/newapp/script.sh;
  executable = true;
};
```

---

## 🆘 Emergency Escapes

Sometimes you need to make a quick fix without a full rebuild:

### Temporarily Override a Managed File
```bash
# Remove the symlink
rm ~/.config/hypr/hyprland.conf

# Copy from your repo (editable now)
cp ~/nixos-config/home/dotfiles/hypr/hyprland.conf ~/.config/hypr/

# Make your emergency fix
nvim ~/.config/hypr/hyprland.conf

# This will work until next rebuild!
# Do not forget to copy your fix back to the repo
cp ~/.config/hypr/hyprland.conf ~/nixos-config/home/dotfiles/hypr/
```

### Quick Package Install (Temporary)
```bash
# Need a package NOW without editing configs?
nix-shell -p package-name

# Or for your whole session:
nix-env -iA nixos.package-name
# WARNING: This is impure - not tracked in your config
# Remove later with: nix-env -e package-name
```

---

## 🔄 Syncing Between Machines

One huge advantage of NixOS: your config is in Git!

### On your main machine (after making changes):
```bash
cd ~/nixos-config
git add -A
git commit -m "Add firefox and update waybar"
git push
```

### On another NixOS machine:
```bash
cd ~/nixos-config
git pull
sudo nixos-rebuild switch --flake .#mnemosyne
# Exact same config as your other machine!
```

This is why we store configs in a repo - your entire system is version controlled and reproducible.

---

## 🎯 TL;DR Cheat Sheet

| Task | Arch Command | NixOS Command |
|------|--------------|---------------|
| Install package | `pacman -S pkg` | Edit `packages.nix` → `rebuild` |
| Remove package | `pacman -R pkg` | Remove from `packages.nix` → `rebuild` |
| Search packages | `pacman -Ss query` | `nix search nixpkgs query` |
| Update system | `pacman -Syu` | `nix flake update && rebuild` |
| Edit hyprland | `nvim ~/.config/hypr/hyprland.conf` | `nvim ~/nixos-config/home/dotfiles/hypr/hyprland.conf` → `rebuild` |
| Add alias | Edit `~/.zshrc` | Edit `home/default.nix` shellAliases → `rebuild` |
| Add script | Create in `~/.local/bin/` | Create in `~/nixos-config/home/dotfiles/bin/` → `rebuild` |
| Enable service | `systemctl enable svc` | Add to `services.nix` → `rebuild` |
| Rollback | Restore backup | `nixos-rebuild switch --rollback` |
| Rebuild | N/A | `sudo nixos-rebuild switch --flake .#mnemosyne` |

---

## 💡 Final Tips for Arch Users

1. **Embrace the rebuild** - It is not a big deal, takes ~30 seconds for config changes
2. **Use Git religiously** - Commit before every rebuild so you can revert
3. **Keep your repo clean** - This IS your system documentation
4. **Test in nix-shell** - Try packages before adding permanently
5. **Read error messages** - Nix errors are verbose but helpful
6. **Use the REPL** - `nix repl` lets you explore packages interactively
7. **Do not fight it** - The declarative model is different but powerful once you adapt

The adjustment period is about 1-2 weeks. After that, you will wonder how you ever managed systems without declarative configuration!

---

## 🔒 Persistence Patterns - What Survives Rebuilds?

This is the **most important concept** for Arch users to understand. On Arch, everything you install or configure just... stays. On NixOS, you need to think about what's declarative vs imperative.

### ❌ What Gets WIPED on Rebuild

| Item | Why | Solution |
|------|-----|----------|
| Manually installed browser extensions | Home Manager regenerates profile | Declare in config |
| GTK/Qt themes set via GUI | Stylix regenerates configs | Use Stylix settings |
| Manually added packages via `nix-env` | Not in flake | Add to `packages.nix` |
| Direct edits to `~/.config/*` (managed files) | Home Manager overwrites | Edit source in repo |
| System services enabled via `systemctl` | Not in config | Add to `services.nix` |

### ✅ What PERSISTS Across Rebuilds

| Item | Why |
|------|-----|
| `~/.local/share/*` | Not managed by Home Manager |
| `~/.cache/*` | Cache directories persist |
| Browser bookmarks/history (in profile) | Profile data persists, just not extensions |
| SSH keys (`~/.ssh/`) | Not managed (and shouldn't be!) |
| GPG keys | Not managed |
| Git repos | Your data, not config |
| Files in `~/Documents`, `~/Pictures`, etc. | User data |

### 🌐 Browser Extensions - The Right Way

**Wrong (Arch way):**
```
Click "Add extension" in browser → Lost on rebuild!
```

**Right (NixOS way):**
```nix
# In home/default.nix
programs.librewolf = {
  enable = true;
  policies.ExtensionSettings = {
    "uBlock0@raymondhill.net" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"\;
      installation_mode = "force_installed";
    };
  };
};
```

**Alternative:** Enable Firefox/Librewolf Sync - extensions sync back after rebuild.

### 📦 Desktop Apps - Declare Custom Entries

If an app needs special flags (like Wayland), create a desktop entry:

```nix
# In home/default.nix
xdg.desktopEntries.brave-browser = {
  name = "Brave";
  exec = "brave --ozone-platform=wayland %U";
  icon = "brave";
  terminal = false;
  categories = [ "Network" "WebBrowser" ];
};
```

### 🔐 Secrets & API Keys

**Never commit secrets directly-50 /home/craig/projects/nixos-asus-vivobook/ARCH-TO-NIXOS.md* Options:

1. **Environment variables** - Set in your shell
2. **agenix/sops-nix** - Encrypted secrets in repo
3. **External files** - Reference files not in git

Example with external file:
```nix
# Read API key from file outside git
environment.variables.WEATHER_API_KEY = 
  builtins.readFile /home/craig/.secrets/weather-api;
```

### 💾 The `flake.lock` File

Your `flake.lock` pins exact versions of nixpkgs/home-manager/stylix. **Commit it!**

```bash
# After successful rebuild
git add flake.lock
git commit -m "chore: pin flake inputs"
git push
```

This ensures:
- Same versions on all machines
- Reproducible builds
- Easy rollback if update breaks something

### 🔄 Hybrid Approach

You don't have to declare EVERYTHING. A pragmatic approach:

| Declare in Config | Leave Imperative |
|-------------------|------------------|
| Critical extensions (uBlock, Bitwarden) | Nice-to-have extensions |
| System packages | `nix-shell` for temp tools |
| Shell aliases & config | Personal scripts in `~/.local/bin` |
| Core services | User systemd services (optional) |

The goal: If your SSD dies, `nixos-rebuild` + restore `~/.ssh` and `~/.local` = back to 95% normal.

