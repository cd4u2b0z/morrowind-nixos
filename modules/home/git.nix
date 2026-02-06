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
    
    settings = {
      user.name = "craig";
      user.email = "masked-elf@pm.me";
      init.defaultBranch = "main";
      pull.rebase = false;
      core.editor = "nvim";
    };
  };

  # Delta for better diffs
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      syntax-theme = "Nord";
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
