{ config, nixpkgsInput, nur-linyinfeng, ... }:

let
  packageOverlays = [
    nur-linyinfeng.overlays.default
  ];
in {
  nixpkgs.overlays = packageOverlays;
}
