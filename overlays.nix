{
  config,
  inputs,
  ...
}:

let
  packageOverlays = [
    inputs.nix4vscode.overlays.default
    inputs.nix-vscode-extensions.overlays.default
    inputs.imap-to-jmap.overlays.stalwart-imap-proxy
    # inputs.nur-linyinfeng.overlays.default
  ];
in
{
  nixpkgs.overlays = packageOverlays;
}
