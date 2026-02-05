# Home Module: Git
#
# Git configuration.
#
# Extracted from: home/default.nix

{ config, lib, pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════════════
  # Git Configuration
  # ═══════════════════════════════════════════════════════════════════
  
  programs.git = {
    enable = true;
    
    userName = "craig";
    userEmail = "masked-elf@pm.me";
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      core.editor = "nvim";
    };
    
    # Delta for better diffs (optional)
    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
        syntax-theme = "Nord";
      };
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # GitHub CLI
  # ═══════════════════════════════════════════════════════════════════
  
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };
}
