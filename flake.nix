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
    hm-extension = {
      url = "github:inmaldrerah/hm-extension";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur-linyinfeng = {
      url = "github:linyinfeng/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager, hm-extension,
    impermanence,
    # lix-module,
    nixvim,
    nur-linyinfeng, ... }:
  let
    triple = "x86_64-unknown-linux-gnu";

    nixosConfig = hostName: {
      name = hostName;
      value = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit hostName;
          nixpkgsInput = nixpkgs;
          inherit nixvim;
          inherit hm-extension;
          inherit nur-linyinfeng;
        };
        modules = [
          {
            nixpkgs.hostPlatform.config = triple;
            networking.hostName = hostName;
            # systemd.services.tailscaled.after = ["NetworkManager-wait-online.service"];
          }
          ./overlays.nix
          home-manager.nixosModules.home-manager
          impermanence.nixosModules.impermanence
          # lix-module.nixosModules.default
          (builtins.getFlake "path:/etc/nixos/private").nixosModules.default
          ./configuration.nix
          ./device/${hostName}
          ./network.nix
          ./storage.nix
          ./users
          ./xkb
        ];
      };
    };
  in
  {
    nixosConfigurations = builtins.listToAttrs (builtins.map nixosConfig [
      "framework-nixos"
      "thinkbook-16-plus-nixos"
      "dell-nixos"
    ]);
  };
}
