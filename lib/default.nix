# Library: Helper Functions
#
# Reusable functions to reduce boilerplate in flake.nix.

{ inputs, ... }:

let
  inherit (inputs.nixpkgs) lib;
in
{
  # ═══════════════════════════════════════════════════════════════════
  # mkHost - Create a NixOS configuration for a host
  # ═══════════════════════════════════════════════════════════════════
  # Usage: mkHost { hostname = "mnemosyne"; username = "craig"; }
  
  mkHost = { hostname, username, system ? "x86_64-linux", extraModules ? [] }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      
      specialArgs = { 
        inherit inputs username;
      };
      
      modules = [
        # NUR overlay for Firefox/Librewolf extensions
        {
          nixpkgs.overlays = [ inputs.nur.overlays.default ];
        }
        
        # Host-specific config
        ../hosts/${hostname}
        
        # Home-manager as NixOS module
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            users.${username} = import ../home;
            extraSpecialArgs = { inherit inputs username; };
          };
        }
      ] ++ extraModules;
    };

  # ═══════════════════════════════════════════════════════════════════
  # forAllSystems - Run function for each supported system
  # ═══════════════════════════════════════════════════════════════════
  
  forAllSystems = function:
    lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      function inputs.nixpkgs.legacyPackages.${system}
    );
}
