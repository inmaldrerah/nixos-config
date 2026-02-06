{
  config,
  inputs,
  ...
}:

let
  packageOverlays = [
    inputs.nix-vscode-extensions.overlays.default
    inputs.nur-linyinfeng.overlays.default
  ];
in
{
  nixpkgs.overlays = packageOverlays;
}
