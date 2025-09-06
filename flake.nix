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
  };

  outputs = {
    self,
    nixpkgs,
    home-manager, ... }:
  let
    triple = "x86_64-unknown-linux-gnu";

    nixosConfig = hostName: {
      name = hostName;
      value = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit hostName;
          nixpkgsInput = nixpkgs;
        };
        modules = [
          {
            nixpkgs.hostPlatform.config = triple;
            networking.hostName = hostName;
          }
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./device/${hostName}
          ./network.nix
          ./users
        ];
      };
    };
  in
  {
    nixosConfigurations = builtins.listToAttrs (builtins.map nixosConfig [
      "framework-nixos"
    ]);
  };
}
