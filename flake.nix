{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    unstable.url = "nixpkgs/nixos-unstable";
    edge.url = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helix = {
      url = "github:gabydd/helix/driver";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    typst-lsp = {
      url = "github:gabydd/typst-lsp";
    };
  };
  outputs = {self, nixpkgs, home-manager, helix, typst-lsp, ... }@inputs: 
  let
    system = "x86_64-linux";
    pkgs-unstable = import inputs.unstable { config.allowUnfree = true; system = system; };
    pkgs-edge = import inputs.edge { config.allowUnfree = true; system = system; };
    nixconfig = {
      nixpkgs = {
        overlays = [
          helix.overlays.default
          (_final: _prev: {
            typst-lsp = typst-lsp.packages.${system}.default;
          })
          (_final: _prev: {
            unstable = pkgs-unstable;
            edge = pkgs-edge;
          })
        ];
      };
    };
  in
  {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./laptop.nix 
          nixconfig
          home-manager.nixosModules.home-manager
          {
            
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages= true;
            home-manager.users.gaby = import ./home.nix;
          }
        ];
      };
      desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./desktop.nix 
          nixconfig
          home-manager.nixosModules.home-manager
          {
            
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages= true;
            home-manager.users.gaby = import ./home.nix;
          }
        ];
      };
    };
  };
}