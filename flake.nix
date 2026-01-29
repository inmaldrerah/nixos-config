{
  description = "NixOS system config";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    nixpkgs-extension = {
      url = "github:inmaldrerah/nixos-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
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
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur-linyinfeng = {
      url = "github:linyinfeng/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-extension,
      home-manager,
      hm-extension,
      impermanence,
      nix-vscode-extensions,
      nur-linyinfeng,
      ...
    }:
    let
      triple = "x86_64-unknown-linux-gnu";

      nixosConfig = hostName: {
        name = hostName;
        value = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit hostName;
            nixpkgsInput = nixpkgs;
            inherit hm-extension;
            inherit nur-linyinfeng;
            inherit nixpkgs-extension;
            inherit nix-vscode-extensions;
          };
          modules = [
            {
              nixpkgs.hostPlatform.config = triple;
              networking.hostName = hostName;
              # systemd.services.tailscaled.after = ["NetworkManager-wait-online.service"];
            }
            ./overlays.nix
            nixpkgs-extension.nixosModules.default
            home-manager.nixosModules.home-manager
            impermanence.nixosModules.impermanence
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
      nixosConfigurations = builtins.listToAttrs (
        map nixosConfig [
          "framework-nixos"
          "thinkbook-16-plus-nixos"
          "dell-nixos"
        ]
      );
    };
}
