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
    hostName = "thinkbook-16-plus-nixos";
    nixpkgsGnu = {
      hostPlatform.config = "x86_64-unknown-linux-gnu";
      overlays = gnuOverlays;
    };
    nixpkgsMusl = {
      hostPlatform.config = "x86_64-unknown-linux-musl";
      overlays = gnuOverlays ++ muslOverlays;
    };
    gnuOverlays = [
      (self: super: rec {
        pkgsGnu = import nixpkgs { localSystem.config = "x86_64-unknown-linux-gnu"; } // { inherit pkgsGnu; };
      })
    ];
    muslOverlays = [
      (self: super: {
        inherit (super.pkgsGnu) greetd wlroots hyprland mesa cage pipewire libopus libpulseaudio ffmpeg_4 openldap xorgserver fftwFloat gtk4 libyaml;
      })
    ];
  in
  {
    nixosConfigurations."${hostName}" = nixpkgs.lib.nixosSystem {
      modules = [
        {
          nixpkgs = nixpkgsGnu;
          networking.hostName = hostName; # Define your hostname.
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
