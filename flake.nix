{
  description = "NixOS system config";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable-small";
    };
    xonsh-pinned-nixpkgs = {
      # url = "github:nixos/nixpkgs/d8fe5e6c92d0d190646fb9f1056741a229980089";
      url = "github:nixos/nixpkgs/8db50d6f207f6e6bea072986fe5abfc955f04bfc";
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

  outputs = { self, nixpkgs, xonsh-pinned-nixpkgs, home-manager, hm-extension, impermanence, neovim-nightly-overlay, nixvim, private }:
  let
    hostName = "thinkbook-16-plus-nixos"; # Define your hostname.
    triple = "x86_64-unknown-linux-gnu";
  in
  {
    nixosConfigurations."${hostName}" = nixpkgs.lib.nixosSystem {
      specialArgs = {
        nixpkgsInput = nixpkgs;
        inherit xonsh-pinned-nixpkgs;
        inherit neovim-nightly-overlay;
        inherit nixvim;
        inherit hm-extension;
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
      ];
    };
  };
}
