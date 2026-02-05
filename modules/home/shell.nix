# Home Module: Shell
#
# Zsh, starship prompt, fzf, shell aliases.
#
# Extracted from: home/default.nix

{ config, lib, pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════════════
  # Zsh
  # ═══════════════════════════════════════════════════════════════════
  
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "docker" "kubectl" "command-not-found" "z" ];
      theme = "";  # Using Starship instead
    };
    
    # Shell aliases
    shellAliases = {
      # Quick shortcuts
      v = "nvim";
      c = "clear";
      q = "exit";
      
      # Power management
      zzz = "systemctl poweroff";
      reboot = "systemctl reboot";
      suspend = "systemctl suspend";
      
      # File listing (with eza if available, fallback to ls)
      ls = "eza --icons --group-directories-first 2>/dev/null || ls --color=auto";
      ll = "eza -la --icons --group-directories-first 2>/dev/null || ls -alF";
      la = "eza -a --icons 2>/dev/null || ls -A";
      l = "eza --icons 2>/dev/null || ls -CF";
      lt = "eza --tree --level=2 --icons 2>/dev/null || tree -L 2";
      
      # Better defaults
      cat = "bat";
      find = "fd";
      grep = "rg";
      top = "btop";
      df = "df -h";
      du = "du -h";
      free = "free -h";
      
      # NixOS system management
      rebuild = "sudo nixos-rebuild switch --flake ~/projects/nixos-asus-vivobook#mnemosyne";
      rebuild-test = "sudo nixos-rebuild test --flake ~/projects/nixos-asus-vivobook#mnemosyne";
      update = "sudo nix flake update ~/projects/nixos-asus-vivobook && sudo nixos-rebuild switch --flake ~/projects/nixos-asus-vivobook#mnemosyne";
      clean = "sudo nix-collect-garbage -d";
      search = "nix search nixpkgs";
      generations = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      
      # File operations (safe)
      cp = "cp -iv";
      mv = "mv -iv";
      rm = "rm -iv";
      mkdir = "mkdir -pv";
      
      # Directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "~" = "cd ~";
      "-" = "cd -";
      
      # Git shortcuts
      g = "git";
      ga = "git add";
      gaa = "git add --all";
      gc = "git commit";
      gcm = "git commit -m";
      gp = "git push";
      gl = "git pull";
      gs = "git status";
      gd = "git diff";
      gco = "git checkout";
      gb = "git branch";
      glog = "git log --oneline --graph --decorate";
      
      # Media
      music = "ncspot";
      play = "playerctl play-pause";
      next = "playerctl next";
      prev = "playerctl previous";
      stop = "playerctl stop";
      
      # Theme management
      wp = "~/.local/bin/wallpaper-manager";
      theme = "~/.config/hypr/scripts/theme-switcher.sh";
      
      # System info
      neofetch = "fastfetch";
      disk = "df -h";
      memory = "free -h";
    };
    
    initContent = ''
      # Source local zshrc if it exists (for machine-specific config)
      if [ -f ~/.zshrc.local ]; then
        source ~/.zshrc.local
      fi
      
      # Add local bin to path
      export PATH="$HOME/.local/bin:$PATH"
      
      # FZF integration
      if command -v fzf &>/dev/null; then
        # FZF options (colors inherited from terminal via Stylix)
        export FZF_DEFAULT_OPTS="--height=50% --layout=reverse --border --margin=1 --padding=1"
        
        # Use ripgrep for FZF if available
        if command -v rg &>/dev/null; then
          export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
          export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        fi
        
        # Preview with bat
        export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :200 {} 2>/dev/null || head -200 {}'"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
        export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {} 2>/dev/null || ls -la {}'"
      fi
      
      # History search with up/down arrows
      bindkey "^[[A" history-search-backward
      bindkey "^[[B" history-search-forward
    '';
  };
  
  # ═══════════════════════════════════════════════════════════════════
  # FZF integration
  # ═══════════════════════════════════════════════════════════════════
  
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  
  # ═══════════════════════════════════════════════════════════════════
  # Starship prompt
  # ═══════════════════════════════════════════════════════════════════
  
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromTOML (builtins.readFile ../../home/dotfiles/starship.toml);
  };
}
