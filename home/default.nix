# Home Manager Configuration
#
# Entry point for home-manager.
# Just imports all the split modules.
#
# The actual config is in modules/home/*.nix

{ config, lib, pkgs, username, ... }:

{
  imports = [
    ../modules/home/xdg.nix        # XDG dirs, gnome-keyring, basics
    ../modules/home/shell.nix      # Zsh, starship, fzf, aliases
    ../modules/home/terminal.nix   # Kitty, tmux
    ../modules/home/editor.nix     # Neovim
    ../modules/home/desktop.nix    # Hyprland, waybar, mako, fuzzel
    ../modules/home/git.nix        # Git config
    ../modules/home/browser.nix    # Librewolf, Brave
    ../modules/home/media.nix      # Cava, fastfetch, mpv
    ../modules/home/theming.nix    # GTK, wallpapers, wallust
  ];
}
