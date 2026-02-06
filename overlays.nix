{
  config,
  nix-vscode-extensions,
  nur-linyinfeng,
  ...
}:

let
  packageOverlays = [
    nix-vscode-extensions.overlays.default
    nur-linyinfeng.overlays.default
  ];
in
{
  nixpkgs.overlays = packageOverlays;
}
