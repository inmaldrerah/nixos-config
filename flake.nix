{
  description = "NixOS system config";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable-small";
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
      url = "github:nix-community/nixvim/d2f733efb4962903b77af330c4c03a63f2f72968";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    private = {
      url = "path:/etc/nixos/private";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur-linyinfeng = {
      url = "github:linyinfeng/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hm-extension, impermanence, neovim-nightly-overlay, nixvim, private, nur-linyinfeng, ... }:
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
        inherit nur-linyinfeng;
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
        ./users
        ./xkb
      ];
    };
  };
}
