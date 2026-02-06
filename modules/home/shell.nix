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
      
      # ── Eza (Morrowind-themed file navigation) ──────────────────
      # Distinct glyphs + icons for every file type in tree/list
      ls = "eza --icons=always --group-directories-first --color=always";
      ll = "eza -lahg --icons=always --group-directories-first --color=always --time-style=relative --git";
      la = "eza -a --icons=always --group-directories-first";
      l  = "eza --icons=always --group-directories-first";
      
      # Tree views — master arrows ── ├── └── for hierarchy
      lt  = "eza --tree --level=2 --icons=always --group-directories-first --color=always";
      lt3 = "eza --tree --level=3 --icons=always --group-directories-first --color=always";
      lt4 = "eza --tree --level=4 --icons=always --group-directories-first --color=always";
      lta = "eza --tree --level=2 --icons=always --group-directories-first --color=always -a";
      ltl = "eza --tree --level=2 --icons=always --group-directories-first --color=always -lahg --git";
      
      # Specialized views
      lsize = "eza -lahgS --icons=always --group-directories-first --color=always --total-size";
      lmod  = "eza -lahg --icons=always --sort=modified --color=always --time-style=relative --git";
      lext  = "eza -lahg --icons=always --sort=extension --group-directories-first --color=always";
      lnew  = "eza -lahg --icons=always --sort=modified --reverse --color=always --time-style=relative";
      lgit  = "eza -lahg --icons=always --group-directories-first --color=always --git --git-repos";
      lnix  = "eza --tree --level=2 --icons=always --color=always '*.nix'";
      
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
      
      # Yazi file manager
      y = "yazi";
      
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
      
      # ── Yazi cd-on-quit wrapper ────────────────────────────────────
      # Opens yazi; on quit, cd to the directory yazi was last in
      function yy() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
      }
      
      # ── Eza Morrowind Color Theme ──────────────────────────────────
      # Colors use 256-color ANSI codes mapped to the Morrowind palette:
      #   38;2;R;G;B = truecolor foreground
      #   Palette reference:
      #     Volcanic bg     #1C1410    Parchment     #D4C4A8
      #     Dwemer gold     #D4A843    Telvanni teal #5B9E8F
      #     Daedric red     #A63D2F    Bitter Coast  #6A8F4D
      #     Silt strider    #C47D3B    Soul gem      #8B5E8B
      #     Azura blue      #4E7BA8    Red Mountain  #7A4535
      #     Ashland stone   #6B5D4F    Bright parch  #F0E6D0
      
      export EZA_COLORS="\
      di=1;38;2;212;168;67:\
      ex=1;38;2;166;61;47:\
      fi=38;2;212;196;168:\
      ln=3;38;2;78;123;168:\
      or=3;1;38;2;166;61;47:\
      pi=38;2;196;125;59:\
      so=38;2;139;94;139:\
      bd=1;38;2;196;125;59:\
      cd=38;2;196;125;59:\
      ur=38;2;212;168;67:\
      uw=38;2;166;61;47:\
      ux=38;2;106;143;77:\
      ue=38;2;106;143;77:\
      gr=38;2;91;158;143:\
      gw=38;2;196;125;59:\
      gx=38;2;106;143;77:\
      tr=38;2;107;93;79:\
      tw=38;2;196;125;59:\
      tx=38;2;106;143;77:\
      su=1;38;2;166;61;47:\
      sf=1;38;2;166;61;47:\
      sn=38;2;91;158;143:\
      sb=38;2;107;93;79:\
      nb=38;2;107;93;79:\
      nk=38;2;91;158;143:\
      nm=38;2;212;168;67:\
      ng=38;2;196;125;59:\
      nt=1;38;2;166;61;47:\
      ub=38;2;107;93;79:\
      uk=38;2;91;158;143:\
      um=38;2;212;168;67:\
      ug=38;2;196;125;59:\
      ut=1;38;2;166;61;47:\
      uu=1;38;2;212;168;67:\
      uR=1;38;2;166;61;47:\
      un=38;2;107;93;79:\
      gu=38;2;91;158;143:\
      gR=1;38;2;166;61;47:\
      gn=38;2;107;93;79:\
      da=38;2;107;93;79:\
      ga=1;38;2;106;143;77:\
      gm=38;2;212;168;67:\
      gd=38;2;166;61;47:\
      gv=38;2;78;123;168:\
      gt=38;2;196;125;59:\
      gi=2;38;2;107;93;79:\
      gc=1;38;2;166;61;47:\
      Gm=1;38;2;212;168;67:\
      Go=38;2;91;158;143:\
      Gc=38;2;106;143;77:\
      Gd=38;2;166;61;47:\
      xx=38;2;107;93;79:\
      hd=4;1;38;2;212;168;67:\
      lp=3;38;2;78;123;168:\
      cc=38;2;196;125;59:\
      mp=1;38;2;91;158;143:\
      im=38;2;139;94;139:\
      vi=38;2;139;94;139:\
      mu=38;2;78;123;168:\
      lo=38;2;78;123;168:\
      cr=1;38;2;166;61;47:\
      do=38;2;196;125;59:\
      co=38;2;122;69;53:\
      tm=2;38;2;107;93;79:\
      cm=2;38;2;107;93;79:\
      bu=1;38;2;106;143;77:\
      sc=38;2;91;158;143:\
      ic=38;2;212;168;67:\
      *.nix=1;38;2;91;158;143:\
      *.toml=38;2;196;125;59:\
      *.yaml=38;2;196;125;59:\
      *.yml=38;2;196;125;59:\
      *.json=38;2;212;168;67:\
      *.lock=2;38;2;107;93;79:\
      *.md=38;2;78;123;168:\
      *.org=38;2;78;123;168:\
      *.txt=38;2;212;196;168:\
      *.log=2;38;2;107;93;79:\
      *.conf=38;2;196;125;59:\
      *.cfg=38;2;196;125;59:\
      *.ini=38;2;196;125;59:\
      *.sh=1;38;2;106;143;77:\
      *.zsh=1;38;2;106;143;77:\
      *.bash=1;38;2;106;143;77:\
      *.fish=1;38;2;106;143;77:\
      *.py=38;2;212;168;67:\
      *.rs=38;2;196;125;59:\
      *.go=38;2;91;158;143:\
      *.js=38;2;212;168;67:\
      *.ts=38;2;78;123;168:\
      *.tsx=38;2;78;123;168:\
      *.jsx=38;2;212;168;67:\
      *.lua=38;2;78;123;168:\
      *.vim=38;2;106;143;77:\
      *.c=38;2;91;158;143:\
      *.h=38;2;91;158;143:\
      *.cpp=38;2;91;158;143:\
      *.hpp=38;2;91;158;143:\
      *.css=38;2;139;94;139:\
      *.scss=38;2;139;94;139:\
      *.html=38;2;196;125;59:\
      *.svg=38;2;139;94;139:\
      *.png=38;2;139;94;139:\
      *.jpg=38;2;139;94;139:\
      *.gif=38;2;139;94;139:\
      *.webp=38;2;139;94;139:\
      *.mp3=38;2;78;123;168:\
      *.flac=38;2;78;123;168:\
      *.wav=38;2;78;123;168:\
      *.mp4=38;2;139;94;139:\
      *.mkv=38;2;139;94;139:\
      *.tar=38;2;122;69;53:\
      *.gz=38;2;122;69;53:\
      *.zip=38;2;122;69;53:\
      *.7z=38;2;122;69;53:\
      *.bak=2;38;2;107;93;79:\
      *.tmp=2;38;2;107;93;79:\
      *.swp=2;38;2;107;93;79:\
      *.o=2;38;2;107;93;79:\
      *.class=2;38;2;107;93;79:\
      Makefile=1;38;2;106;143;77:\
      Dockerfile=1;38;2;91;158;143:\
      flake.nix=1;38;2;212;168;67:\
      flake.lock=2;38;2;107;93;79:\
      .gitignore=2;38;2;107;93;79:\
      README*=4;38;2;212;168;67:\
      LICENSE*=38;2;107;93;79"
      
      export EZA_ICON_SPACING=2
      
      # FZF integration
      if command -v fzf &>/dev/null; then
        # FZF Morrowind color scheme
        export FZF_DEFAULT_OPTS="\
          --height=50% --layout=reverse --border --margin=1 --padding=1 \
          --color=fg:#D4C4A8,bg:#1C1410,hl:#D4A843 \
          --color=fg+:#F0E6D0,bg+:#2A211A,hl+:#E0B84A \
          --color=info:#5B9E8F,prompt:#D4A843,pointer:#A63D2F \
          --color=marker:#6A8F4D,spinner:#8B5E8B,header:#C47D3B \
          --color=border:#6B5D4F,gutter:#1C1410 \
          --prompt='❯ ' --pointer='▶' --marker='✦'"
        
        # Use ripgrep for FZF if available
        if command -v rg &>/dev/null; then
          export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
          export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        fi
        
        # Preview with bat
        export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :200 {} 2>/dev/null || head -200 {}'"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
        export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always --icons=always {} 2>/dev/null || ls -la {}'"
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
