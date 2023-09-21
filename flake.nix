{
  description = "flake NixOS system config";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
      # url = "github:inmaldrerah/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      # url = "github:inmaldrerah/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
  };

  outputs = { self, nixpkgs, home-manager, impermanence }:
  let
    hostName = "thinkbook-16-plus-nixos";
    pkgsGnu = (import nixpkgs {
      localSystem.config = "x86_64-unknown-linux-gnu";
      config = {
        inherit packageOverrides;
      };
    }) // { inherit pkgsGnu; };
    pkgsMusl = (import nixpkgs {
      localSystem.config = "x86_64-unknown-linux-musl";
      config = {
        packageOverrides = pkgs:
        let
          specialOverrides = {
            inherit (pkgsGnu) greetd wlroots hyprland mesa cage pipewire libopus libpulseaudio ffmpeg_4 openldap xorgserver fftwFloat gtk4 libyaml;
          };
        in specialOverrides // (packageOverrides pkgs // specialOverrides);
      };
    }) // { inherit pkgsGnu; };
    packageOverrides = pkgs: {
      waybar = pkgs.waybar.overrideAttrs (oldAttrs: rec {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      });
    };
    pkgs = pkgsGnu;
  in
  {
    nixosConfigurations."${hostName}" = nixpkgs.lib.nixosSystem {
      pkgs = pkgs;
      modules = [
        home-manager.nixosModules.home-manager
        impermanence.nixosModules.impermanence
        ./configuration.nix
        ./hardware.nix
        ./network.nix
        ./storage.nix
        ./users.nix
        ./user-secrets.nix
        {
          nixpkgs = {
            pkgs = pkgs;
          };
          networking.hostName = hostName; # Define your hostname.
        }
      ];
    };
  };
}
