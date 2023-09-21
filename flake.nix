{
  description = "NixOS system config";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable-small";
    };
  };

  outputs = { self, nixpkgs, ... }:
  let
    hostName = "thinkbook-16-plus-nixos"; # Define your hostname.
    triple = "x86_64-unknown-linux-gnu";
  in
  {
    nixosConfigurations."${hostName}" = nixpkgs.lib.nixosSystem {
      specialArgs = {
        nixpkgsInput = nixpkgs;
      };
      modules = [
        {
          nixpkgs.hostPlatform.config = triple;
          networking.hostName = hostName;
        }
        ./overlays.nix
        ./configuration.nix
        ./hardware.nix
        ./network.nix
        ./storage.nix
        ./users
        ./xkb
      ];
    };
  };
}
