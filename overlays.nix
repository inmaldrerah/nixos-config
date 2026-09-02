{
  config,
  inputs,
  ...
}:

let
  packageOverlays = [
    inputs.nix4vscode.overlays.default
    inputs.nix-vscode-extensions.overlays.default
    # inputs.nur-linyinfeng.overlays.default
  ];
  imapToJmap = final: prev: {
    stalwart-imap-proxy = inputs.imap-to-jmap.packages.${final.system}.default;
  };
in
{
  nixpkgs.overlays = packageOverlays ++ [ imapToJmap ];
}
