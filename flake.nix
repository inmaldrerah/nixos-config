{
  description = "NixOS system config";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    private = {
      url = "path:/etc/nixos/private";
    };
  };

  outputs = { self, nixpkgs, home-manager, impermanence, private }:
  let
    hostName = "thinkbook-16-plus-nixos"; # Define your hostname.
    triple = "x86_64-unknown-linux-gnu";
  in
  {
    nixosConfigurations."${hostName}" = nixpkgs.lib.nixosSystem {
      specialArgs = {
        nixpkgsFun = import nixpkgs;
      };
      modules = [
        {
          nixpkgs.hostPlatform.config = triple;
          networking.hostName = hostName;
        }
        ./overlays.nix
        home-manager.nixosModules.home-manager
        impermanence.nixosModules.impermanence
        private.nixosModules.default
        ./configuration.nix
        ./hardware.nix
        ./network.nix
        ./storage.nix
        ./users.nix
      ];
    };
  };
}
