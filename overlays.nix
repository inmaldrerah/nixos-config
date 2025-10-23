{ config, nixpkgsInput, nur-linyinfeng, ... }:

let
  packageOverlays = [
    (final: prev: {
      shell = prev.writeShellApplication {
        name = "shell-starter";
        text = ''
          /bin/sh $HOME/.shell $@
        '';
      };
    })
    nur-linyinfeng.overlays.default
  ];
in {
  nixpkgs.overlays = packageOverlays;
}
