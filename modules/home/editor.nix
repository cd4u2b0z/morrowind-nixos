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
    
    # Nix-compiled treesitter parsers — correct linking, reproducible, offline
    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins (p: [
        p.bash p.c p.diff p.html p.javascript p.jsdoc p.json
        p.lua p.luadoc p.luap p.markdown p.markdown_inline p.python
        p.query p.regex p.toml p.tsx p.typescript p.vim p.vimdoc p.yaml
        p.nix  # for editing this config!
      ]))
    ];

    # Dependencies for plugins (telescope, treesitter, etc.)
    extraPackages = with pkgs; [
      # Telescope dependencies
      ripgrep
      fd
      
      # Treesitter
      tree-sitter
      # gcc no longer needed — parsers compiled by Nix
      
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
