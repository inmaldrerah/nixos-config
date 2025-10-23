{ config, nixpkgsInput, nixpkgs-extension, nur-linyinfeng, ... }:

let
  packageOverlays = [
    nixpkgs-extension.overlays.default
    nur-linyinfeng.overlays.default
  ];
in {
  nixpkgs.overlays = packageOverlays;
}
