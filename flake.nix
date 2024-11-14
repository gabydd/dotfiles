{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    unstable.url = "nixpkgs/nixos-unstable";
    edge.url = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty = {
      url = "git+ssh://git@github.com/ghostty-org/ghostty";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    zig.url = "github:mitchellh/zig-overlay";
    zls.url = "github:zigtools/zls";
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {self, nixpkgs, home-manager, helix, ghostty, nixos-cosmic, zig, zls, ... }@inputs: 
  let
    system = "x86_64-linux";
    pkgs-unstable = import inputs.unstable { config.allowUnfree = true; system = system; };
    pkgs-edge = import inputs.edge { config.allowUnfree = true; system = system; };
    nixconfig = {
      nixpkgs = {
        overlays = [
          helix.overlays.default
          (_final: _prev: {
            ghostty = ghostty.packages.${system}.default;
            zig = zig.packages.${system}.default;
            zls = zls.packages.${system}.default;
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
        ];
      };
    };
  };
}
