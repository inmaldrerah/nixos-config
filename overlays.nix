{ inputs, ... }:
let
  # Shared with the home flake, see ./nixpkgs-shared.nix
  shared = import ./nixpkgs-shared.nix { inherit inputs; };
in
{
  nixpkgs.overlays = shared.overlays;
  nixpkgs.config = shared.config;
}
