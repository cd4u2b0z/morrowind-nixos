{
  description = "NixOS configuration for ASUS Vivobook S15 with Niri";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Niri compositor
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, niri, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      
      # Your username from Ansible config
      username = "craig";
      hostname = "vivobook";
      
    in {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        
        specialArgs = { 
          inherit inputs username;
        };
        
        modules = [
          # Hardware configuration
          ./hardware-configuration.nix
          
          # Core system configuration
          ./modules/system.nix
          
          # Niri compositor
          niri.nixosModules.niri
          ./modules/niri.nix
          
          # Services
          ./modules/services.nix
          
          # Packages
          ./modules/packages.nix
          
          # Home Manager integration
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              
              users.${username} = import ./home;
              
              extraSpecialArgs = { 
                inherit inputs username;
              };
            };
          }
        ];
      };
    };
}
