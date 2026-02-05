# Home Module: Editor
#
# Neovim configuration with LSPs, Treesitter, etc.
#
# Extracted from: home/default.nix

{ config, lib, pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════════════
  # Neovim (with Lazy.nvim, Telescope, Treesitter, LSP)
  # ═══════════════════════════════════════════════════════════════════
  
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    
    # Dependencies for plugins (telescope, treesitter, etc.)
    extraPackages = with pkgs; [
      # Telescope dependencies
      ripgrep
      fd
      
      # Treesitter
      tree-sitter
      gcc  # for treesitter compilation
      
      # LSP servers
      lua-language-server
      nil  # Nix LSP
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted  # HTML/CSS/JSON
      pyright  # Python
      rust-analyzer
      
      # Formatters
      stylua
      nixpkgs-fmt
      prettierd
      black
      
      # Other tools
      lazygit  # for lazygit.nvim
    ];
  };
  
  # Neovim config directory (your full Arch config with lazy.nvim)
  xdg.configFile."nvim" = {
    source = ../../home/dotfiles/nvim;
    recursive = true;
  };
}
