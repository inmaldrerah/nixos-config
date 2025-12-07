{
  config,
  nixpkgsInput,
  nixpkgs-extension,
  nix-vscode-extensions,
  nur-linyinfeng,
  ...
}:

let
  packageOverlays = [
    # nixpkgs-extension.overlays.default
    nix-vscode-extensions.overlays.default
    nur-linyinfeng.overlays.default
  ];
in
{
  nixpkgs.overlays = packageOverlays;
}
