# NixOS Architecture Guide

A comprehensive guide to understanding NixOS, Nix Flakes, and maintaining this system configuration.

---

## Table of Contents

1. [What is NixOS?](#what-is-nixos)
2. [The Nix Language](#the-nix-language)
3. [How Nix Builds Work](#how-nix-builds-work)
4. [Understanding Flakes](#understanding-flakes)
5. [This Configuration's Architecture](#this-configurations-architecture)
6. [Home Manager](#home-manager)
7. [The Nix Store](#the-nix-store)
8. [Building & Rebuilding](#building--rebuilding)
9. [System Maintenance](#system-maintenance)
10. [Troubleshooting](#troubleshooting)
11. [Advanced Topics](#advanced-topics)

---

## What is NixOS?

NixOS is a **declarative** Linux distribution built on the Nix package manager. Instead of imperatively installing packages and modifying config files, you **declare** what your system should look like, and NixOS builds it for you.

### Key Principles

| Principle | Traditional Linux | NixOS |
|-----------|------------------|-------|
| **Configuration** | Scattered files in /etc | Single declarative configuration |
| **Package Installation** | Mutates system state | Builds immutable packages |
| **Upgrades** | In-place modification | Atomic generation switch |
| **Rollbacks** | Requires snapshots/backups | Built-in, instant |
| **Reproducibility** | "Works on my machine" | Guaranteed identical builds |

### The Declarative Model

```
┌─────────────────────────────────────────────────────────────────┐
│                    YOUR CONFIGURATION                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │ flake.nix   │  │ modules/*.nix│  │ home/*.nix │             │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘             │
│         │                │                │                     │
│         └────────────────┼────────────────┘                     │
│                          ▼                                      │
│                 ┌─────────────────┐                             │
│                 │  nix evaluate   │                             │
│                 └────────┬────────┘                             │
│                          ▼                                      │
│                 ┌─────────────────┐                             │
│                 │   nix build     │                             │
│                 └────────┬────────┘                             │
│                          ▼                                      │
│                 ┌─────────────────┐                             │
│                 │  /nix/store/... │  ← Immutable result         │
│                 └────────┬────────┘                             │
│                          ▼                                      │
│                 ┌─────────────────┐                             │
│                 │ System Profile  │  ← Atomic switch            │
│                 └─────────────────┘                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## The Nix Language

Nix uses a **pure, lazy, functional** language for configuration.

### Basic Syntax

```nix
# Attribute sets (like JSON objects)
{
  name = "value";
  nested = {
    key = "value";
  };
}

# Lists
[ "item1" "item2" "item3" ]

# Functions
myFunction = x: x + 1;
myFunction 5  # Returns 6

# Let bindings (local variables)
let
  x = 10;
  y = 20;
in
  x + y  # Returns 30

# With statement (bring attributes into scope)
with pkgs; [ firefox kitty neovim ]
# Equivalent to: [ pkgs.firefox pkgs.kitty pkgs.neovim ]

# Conditionals
if condition then "yes" else "no"

# String interpolation
"Hello ${name}, you have ${toString count} items"

# Multi-line strings
''
  This is a
  multi-line string
''

# Import other files
import ./other-file.nix
```

### Module System

NixOS uses a **module system** that merges configurations:

```nix
# A NixOS module has this structure:
{ config, lib, pkgs, ... }:
{
  # Options this module provides
  options = { ... };
  
  # Configuration this module sets
  config = { ... };
  
  # Or shorthand (just config):
  imports = [ ./other-module.nix ];
  
  environment.systemPackages = [ pkgs.vim ];
  services.nginx.enable = true;
}
```

The magic: **Multiple modules can set the same option**, and NixOS merges them intelligently:

```nix
# Module A
environment.systemPackages = [ pkgs.vim ];

# Module B  
environment.systemPackages = [ pkgs.git ];

# Result (merged automatically)
environment.systemPackages = [ pkgs.vim pkgs.git ];
```

---

## How Nix Builds Work

### The Build Process

```
┌──────────────────────────────────────────────────────────────┐
│ 1. EVALUATION PHASE                                          │
│    ┌─────────────┐                                           │
│    │ flake.nix   │ ──► Nix evaluates expressions             │
│    └─────────────┘     Produces "derivations" (.drv files)   │
│                                                              │
│ 2. BUILD PHASE                                               │
│    ┌─────────────┐                                           │
│    │ derivations │ ──► Nix builds each derivation            │
│    └─────────────┘     Downloads from cache or builds locally│
│                                                              │
│ 3. RESULT                                                    │
│    ┌─────────────────────────────────────────┐               │
│    │ /nix/store/abc123...-package-1.0        │               │
│    │ /nix/store/def456...-other-package-2.0  │               │
│    │ /nix/store/ghi789...-nixos-system-...   │               │
│    └─────────────────────────────────────────┘               │
└──────────────────────────────────────────────────────────────┘
```

### Derivations

A **derivation** is a build recipe. It specifies:
- Source files
- Build dependencies
- Build commands
- Output path

```nix
# Simplified derivation concept
derivation {
  name = "hello-1.0";
  builder = "${pkgs.bash}/bin/bash";
  src = ./src;
  buildInputs = [ pkgs.gcc ];
}
```

### Content-Addressable Storage

Every package path includes a **hash** of all its inputs:

```
/nix/store/abc123def456ghi789...-firefox-120.0
           ^^^^^^^^^^^^^^^^^^^^^^^^
           Hash of: source code + dependencies + build flags + ...
```

**Why this matters:**
- Same inputs = same hash = same output (reproducible!)
- Different versions coexist (no "dependency hell")
- Atomic upgrades (old version stays until you switch)

---

## Understanding Flakes

Flakes are Nix's answer to reproducibility and composability.

### What Problems Flakes Solve

| Problem | Without Flakes | With Flakes |
|---------|---------------|-------------|
| **Pinning versions** | Manual, error-prone | `flake.lock` handles it |
| **Composing configs** | Channels, overlays, complexity | Simple `inputs` |
| **Sharing configs** | Copy files, hope it works | `nix flake clone` |
| **Reproducibility** | "It worked yesterday" | Guaranteed same result |

### Flake Structure

```nix
{
  description = "My NixOS configuration";

  # ┌─────────────────────────────────────────────────────────────┐
  # │ INPUTS: External dependencies (like package.json)          │
  # └─────────────────────────────────────────────────────────────┘
  inputs = {
    # Main package repository
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Home Manager for user configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";  # Use same nixpkgs
    };
    
    # Niri compositor
    niri.url = "github:sodiboo/niri-flake";
  };

  # ┌─────────────────────────────────────────────────────────────┐
  # │ OUTPUTS: What this flake provides                           │
  # └─────────────────────────────────────────────────────────────┘
  outputs = { self, nixpkgs, home-manager, niri, ... }:
  {
    # NixOS system configurations
    nixosConfigurations.vivobook = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix
        ./modules/system.nix
        # ...
      ];
    };
    
    # Home Manager configurations (standalone)
    homeConfigurations."user@host" = home-manager.lib.homeManagerConfiguration {
      # ...
    };
    
    # Development shells
    devShells.x86_64-linux.default = pkgs.mkShell {
      # ...
    };
  };
}
```

### The Lock File

`flake.lock` pins exact versions:

```json
{
  "nodes": {
    "nixpkgs": {
      "locked": {
        "lastModified": 1706091478,
        "narHash": "sha256-abc123...",
        "owner": "nixos",
        "repo": "nixpkgs",
        "rev": "abc123def456...",
        "type": "github"
      }
    }
  }
}
```

**This ensures:**
- Everyone gets the exact same packages
- Builds are reproducible across machines
- Updates are intentional (`nix flake update`)

---

## This Configuration's Architecture

### Directory Structure

```
nixos-asus-vivobook/
│
├── flake.nix                    # Entry point - defines inputs and outputs
├── flake.lock                   # Locked dependency versions (auto-generated)
│
├── hardware-configuration.nix   # Hardware-specific: CPU, GPU, disks, drivers
│
├── modules/
│   ├── system.nix              # Users, locale, timezone, Nix settings
│   ├── niri.nix                # Niri compositor, Wayland, fonts, portals
│   ├── packages.nix            # All system packages
│   └── services.nix            # NetworkManager, Bluetooth, PipeWire, etc.
│
└── home/
    ├── default.nix             # Home Manager entry point
    └── dotfiles/
        ├── niri/
        │   ├── config.kdl      # Niri keybindings and settings
        │   └── scripts/        # Wallpaper, screenshot scripts
        ├── waybar/
        │   ├── config          # Waybar modules configuration
        │   ├── style.css       # Waybar styling
        │   └── scripts/        # Waybar module scripts
        ├── kitty/
        │   └── kitty.conf
        ├── mako/
        │   └── config
        ├── fuzzel/
        │   └── fuzzel.ini
        └── ...
```

### Data Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                          flake.nix                                  │
│  Defines: inputs (nixpkgs, home-manager, niri)                      │
│           outputs (nixosConfigurations.vivobook)                    │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    nixosSystem { modules = [...] }                  │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
┌───────────────┐     ┌─────────────────┐     ┌─────────────────┐
│ hardware-     │     │ modules/        │     │ home-manager    │
│ configuration │     │ *.nix           │     │ integration     │
│ .nix          │     │                 │     │                 │
├───────────────┤     ├─────────────────┤     ├─────────────────┤
│ • CPU config  │     │ • system.nix    │     │ • home/         │
│ • GPU drivers │     │ • niri.nix      │     │   default.nix   │
│ • Filesystems │     │ • packages.nix  │     │ • dotfiles/     │
│ • Boot loader │     │ • services.nix  │     │                 │
└───────────────┘     └─────────────────┘     └─────────────────┘
        │                       │                       │
        └───────────────────────┼───────────────────────┘
                                ▼
                    ┌─────────────────────┐
                    │  Merged NixOS       │
                    │  Configuration      │
                    └──────────┬──────────┘
                               ▼
                    ┌─────────────────────┐
                    │  /nix/store/...     │
                    │  -nixos-system-     │
                    │  vivobook           │
                    └─────────────────────┘
```

### Module Responsibilities

| Module | Responsibility |
|--------|----------------|
| `flake.nix` | Entry point, input management, module composition |
| `hardware-configuration.nix` | Hardware detection, drivers, boot, filesystems |
| `modules/system.nix` | Users, locales, timezone, Nix settings |
| `modules/niri.nix` | Compositor, Wayland environment, fonts, XDG portals |
| `modules/packages.nix` | All installable packages |
| `modules/services.nix` | System services (network, audio, bluetooth) |
| `home/default.nix` | User config, dotfiles, theming |

---

## Home Manager

Home Manager manages **user-level configuration** declaratively.

### System vs User Configuration

```
┌────────────────────────────────────────────────────────────────┐
│                    SYSTEM LEVEL (NixOS)                        │
│  • Root-owned files (/etc/*)                                   │
│  • System services (systemd system units)                      │
│  • Kernel, boot, hardware                                      │
│  • Global packages                                             │
│  Managed by: nixos-rebuild                                     │
└────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────────┐
│                    USER LEVEL (Home Manager)                   │
│  • User dotfiles (~/.config/*)                                 │
│  • User services (systemd user units)                          │
│  • User packages                                               │
│  • Themes, fonts (user scope)                                  │
│  Managed by: home-manager switch (or via NixOS module)         │
└────────────────────────────────────────────────────────────────┘
```

### Integration Mode (This Config)

We use **NixOS module integration** - Home Manager runs as part of `nixos-rebuild`:

```nix
# In flake.nix
modules = [
  home-manager.nixosModules.home-manager
  {
    home-manager = {
      useGlobalPkgs = true;      # Use system's nixpkgs
      useUserPackages = true;    # Install to user profile
      users.craig = import ./home;
    };
  }
];
```

### Home Manager Features

```nix
# home/default.nix
{ config, pkgs, ... }:
{
  # Manage dotfiles
  xdg.configFile."kitty/kitty.conf".source = ./dotfiles/kitty/kitty.conf;
  
  # Or generate them
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "you@example.com";
  };
  
  # User services
  services.mako.enable = true;
  
  # User packages
  home.packages = with pkgs; [ spotify discord ];
  
  # Theming
  gtk = {
    enable = true;
    theme.name = "adw-gtk3-dark";
  };
}
```

---

## The Nix Store

### How It Works

```
/nix/store/
├── abc123...-glibc-2.38/
│   ├── lib/
│   │   └── libc.so.6
│   └── ...
├── def456...-firefox-120.0/
│   ├── bin/
│   │   └── firefox           # Hardcoded paths to dependencies
│   └── lib/
│       └── ... → /nix/store/abc123...-glibc-2.38/lib/...
├── ghi789...-nixos-system-vivobook-24.05/
│   └── ... (entire system derivation)
└── ...
```

### Key Properties

1. **Immutable**: Files in /nix/store never change after creation
2. **Content-addressed**: Path includes hash of all inputs
3. **Self-contained**: Each package has all dependencies embedded
4. **Garbage collected**: Unused packages can be cleaned up

### Profiles and Generations

```
/nix/var/nix/profiles/
├── system -> system-42-link
├── system-42-link -> /nix/store/...-nixos-system-vivobook/
├── system-41-link -> /nix/store/...-nixos-system-vivobook/  (previous)
├── system-40-link -> /nix/store/...-nixos-system-vivobook/  (older)
└── ...

# Each generation is a complete, bootable system!
```

---

## Building & Rebuilding

### Common Commands

```bash
# ═══════════════════════════════════════════════════════════════
# SYSTEM REBUILDS
# ═══════════════════════════════════════════════════════════════

# Build and switch to new configuration (most common)
sudo nixos-rebuild switch --flake .#vivobook

# Build and switch, but don't add to boot menu
sudo nixos-rebuild test --flake .#vivobook

# Build only (don't switch) - useful for testing
nixos-rebuild build --flake .#vivobook

# Build with verbose output
sudo nixos-rebuild switch --flake .#vivobook --show-trace

# ═══════════════════════════════════════════════════════════════
# FLAKE OPERATIONS
# ═══════════════════════════════════════════════════════════════

# Update all inputs (nixpkgs, home-manager, niri, etc.)
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# Check flake for errors
nix flake check

# Show flake info
nix flake show
nix flake metadata

# ═══════════════════════════════════════════════════════════════
# PACKAGE OPERATIONS
# ═══════════════════════════════════════════════════════════════

# Search for packages
nix search nixpkgs firefox

# Try a package temporarily (doesn't install)
nix shell nixpkgs#cowsay

# Run a package without installing
nix run nixpkgs#cowsay -- "Hello"

# ═══════════════════════════════════════════════════════════════
# GENERATIONS & ROLLBACK
# ═══════════════════════════════════════════════════════════════

# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Boot into specific generation (at GRUB menu)
# Select from boot menu

# ═══════════════════════════════════════════════════════════════
# GARBAGE COLLECTION
# ═══════════════════════════════════════════════════════════════

# Remove old generations (keep last 7 days)
sudo nix-collect-garbage --delete-older-than 7d

# Remove ALL old generations (careful!)
sudo nix-collect-garbage -d

# Optimize store (deduplicate)
sudo nix-store --optimise
```

### Build Process Deep Dive

```
┌─────────────────────────────────────────────────────────────────┐
│ $ sudo nixos-rebuild switch --flake .#vivobook                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 1. READ FLAKE                                                   │
│    • Parse flake.nix                                            │
│    • Read flake.lock for pinned versions                        │
│    • Fetch inputs if not cached                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. EVALUATE                                                     │
│    • Evaluate Nix expressions                                   │
│    • Merge all modules                                          │
│    • Produce derivation tree                                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. BUILD                                                        │
│    For each derivation:                                         │
│    • Check binary cache (cache.nixos.org)                       │
│    • If cached: download                                        │
│    • If not: build locally                                      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. ACTIVATE                                                     │
│    • Create new generation                                      │
│    • Update /run/current-system symlink                         │
│    • Run activation scripts                                     │
│    • Restart changed services                                   │
│    • Update boot loader                                         │
└─────────────────────────────────────────────────────────────────┘
```

---

## System Maintenance

### Regular Maintenance Schedule

| Task | Frequency | Command |
|------|-----------|---------|
| Update packages | Weekly/Monthly | `nix flake update && sudo nixos-rebuild switch --flake .#vivobook` |
| Garbage collect | Monthly | `sudo nix-collect-garbage --delete-older-than 30d` |
| Optimize store | Quarterly | `sudo nix-store --optimise` |
| Review generations | Monthly | `sudo nix-env --list-generations -p /nix/var/nix/profiles/system` |

### Adding Packages

1. Edit `modules/packages.nix`:
   ```nix
   environment.systemPackages = with pkgs; [
     # ... existing packages ...
     newpackage  # Add here
   ];
   ```

2. Rebuild:
   ```bash
   sudo nixos-rebuild switch --flake .#vivobook
   ```

### Updating the System

```bash
cd /etc/nixos  # or wherever your flake is

# Update flake.lock with latest versions
nix flake update

# Review what changed (optional)
git diff flake.lock

# Rebuild with new versions
sudo nixos-rebuild switch --flake .#vivobook

# If something breaks, rollback
sudo nixos-rebuild switch --rollback
```

### Configuration Changes Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. EDIT CONFIGURATION                                           │
│    $ nvim modules/packages.nix                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. TEST BUILD (optional but recommended)                        │
│    $ nixos-rebuild build --flake .#vivobook                     │
│    (Catches errors without changing system)                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. APPLY CHANGES                                                │
│    $ sudo nixos-rebuild switch --flake .#vivobook               │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. COMMIT TO GIT                                                │
│    $ git add -A && git commit -m "Add package X"                │
│    $ git push                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Troubleshooting

### Build Errors

```bash
# Show detailed error trace
sudo nixos-rebuild switch --flake .#vivobook --show-trace

# Check flake syntax
nix flake check

# Evaluate without building (faster error checking)
nix eval .#nixosConfigurations.vivobook.config.system.build.toplevel
```

### Common Issues

| Error | Cause | Solution |
|-------|-------|----------|
| `error: attribute 'X' missing` | Typo in package name | Check `nix search nixpkgs X` |
| `collision between X and Y` | Package conflict | Remove one or use priorities |
| `infinite recursion` | Circular dependency | Check imports and `with` statements |
| `hash mismatch` | Source changed | Run `nix flake update` |
| `permission denied` | Need root | Use `sudo` for system rebuild |

### Recovery Mode

If system won't boot:

1. **At GRUB menu**: Select previous generation
2. **From NixOS USB**:
   ```bash
   # Mount your partitions
   sudo mount /dev/disk/by-label/NIXOS /mnt
   sudo mount /dev/disk/by-label/BOOT /mnt/boot
   
   # Enter system
   sudo nixos-enter --root /mnt
   
   # Fix configuration and rebuild
   cd /etc/nixos
   # ... fix the issue ...
   nixos-rebuild switch --flake .#vivobook
   ```

---

## Advanced Topics

### Overlays

Modify packages without forking nixpkgs:

```nix
nixpkgs.overlays = [
  (final: prev: {
    # Override a package
    myPackage = prev.myPackage.override {
      someFlag = true;
    };
    
    # Add a new package
    customTool = final.callPackage ./pkgs/custom-tool {};
  })
];
```

### Custom Packages

```nix
# pkgs/my-tool/default.nix
{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "my-tool";
  version = "1.0.0";
  
  src = fetchFromGitHub {
    owner = "someone";
    repo = "my-tool";
    rev = "v${version}";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };
  
  buildInputs = [ ];
  
  installPhase = ''
    mkdir -p $out/bin
    cp my-tool $out/bin/
  '';
}
```

### Secrets Management

For sensitive data, use **agenix** or **sops-nix**:

```nix
# Don't do this:
services.myService.password = "secret123";  # Stored in nix store!

# Do this instead:
age.secrets.myPassword.file = ./secrets/password.age;
services.myService.passwordFile = config.age.secrets.myPassword.path;
```

### Development Shells

Create reproducible development environments:

```nix
# flake.nix
outputs = { self, nixpkgs, ... }:
let
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
in {
  devShells.x86_64-linux.default = pkgs.mkShell {
    buildInputs = with pkgs; [
      python3
      nodejs
      rustc
      cargo
    ];
    
    shellHook = ''
      echo "Development environment loaded!"
    '';
  };
};

# Usage:
# $ nix develop
```

---

## Resources

### Official Documentation
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)

### Learning Resources
- [Nix Pills](https://nixos.org/guides/nix-pills/) - Deep dive tutorials
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/) - Modern guide
- [zero-to-nix](https://zero-to-nix.com/) - Interactive introduction

### Community
- [NixOS Discourse](https://discourse.nixos.org/)
- [Nix/NixOS Matrix](https://matrix.to/#/#nix:nixos.org)
- [r/NixOS](https://reddit.com/r/NixOS)

### This Configuration
- [Niri Documentation](https://github.com/YaLTeR/niri/wiki)
- [Niri Flake](https://github.com/sodiboo/niri-flake)

---

**Remember**: NixOS has a learning curve, but once you understand it, you'll never want to go back to imperative system management. Every change is tracked, every configuration is reproducible, and you can always roll back.

Happy hacking! 🚀
