# NixOS Configuration - Dendritic Structure
#
# Entry point for the entire configuration.
# This should stay minimal - complexity lives in modules/profiles.
#
# Rebuild:  sudo nixos-rebuild switch --flake .#mnemosyne
# Test:     sudo nixos-rebuild test --flake .#mnemosyne
# Update:   nix flake update && sudo nixos-rebuild switch --flake .#mnemosyne

{
  description = "NixOS configuration for ASUS Vivobook S15 with Hyprland";

  # ═══════════════════════════════════════════════════════════════════
  # Inputs
  # ═══════════════════════════════════════════════════════════════════
  
  inputs = {
    # Core
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Stylix - system-wide theming
    stylix.url = "github:danth/stylix";
    
    # NUR - Nix User Repository (for Firefox/Librewolf extensions)
    nur.url = "github:nix-community/NUR";
  };

  # ═══════════════════════════════════════════════════════════════════
  # Outputs
  # ═══════════════════════════════════════════════════════════════════
  
  outputs = { self, nixpkgs, home-manager, stylix, nur, ... }@inputs:
    let
      # Import helper library
      myLib = import ./lib { inherit inputs; };
      
      # Common variables
      username = "craig";
      
    in {
      # ─────────────────────────────────────────────────────────────────
      # NixOS Configurations
      # ─────────────────────────────────────────────────────────────────
      
      nixosConfigurations = {
        # Primary laptop
        mnemosyne = myLib.mkHost {
          hostname = "mnemosyne";
          inherit username;
        };
        
        # Add more machines here:
        # server = myLib.mkHost { hostname = "server"; inherit username; };
      };

      # ─────────────────────────────────────────────────────────────────
      # Dev shell for working on this config
      # ─────────────────────────────────────────────────────────────────
      
      devShells = myLib.forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nil           # Nix LSP
            nixpkgs-fmt   # Formatter
          ];
        };
      });
    };
}
