{
  description = "NixOS system config";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable-small";
    };
    lix = {
      url = "git+https://git@git.lix.systems/lix-project/lix?ref=refs/tags/2.90-beta.1";
      flake = false;
    };
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.lix.follows = "lix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hm-extension = {
      # url = "path:/home/inme/Builds/hm-extension";
      url = "github:inmaldrerah/hm-extension";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    private = {
      url = "path:/etc/nixos/private";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, lix-module, home-manager, hm-extension, impermanence, neovim-nightly-overlay, nixvim, private, ... }:
  let
    hostName = "thinkbook-16-plus-nixos"; # Define your hostname.
    triple = "x86_64-unknown-linux-gnu";
  in
  {
    nixosConfigurations."${hostName}" = nixpkgs.lib.nixosSystem {
      specialArgs = {
        nixpkgsInput = nixpkgs;
        inherit neovim-nightly-overlay;
        inherit nixvim;
        inherit hm-extension;
      };
      modules = [
        {
          nixpkgs.hostPlatform.config = triple;
          networking.hostName = hostName;
        }
        lix-module.nixosModules.default
        ./overlays.nix
        home-manager.nixosModules.home-manager
        impermanence.nixosModules.impermanence
        private.nixosModules.default
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
