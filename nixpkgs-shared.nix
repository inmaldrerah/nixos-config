# Shared nixpkgs instantiation settings: imported by the system flake (through
# ./overlays.nix) and, via the `sys` input's outPath, by the standalone home
# flake in ~/.config/home-manager. Single source on purpose: both sides must
# instantiate nixpkgs identically or the same package gets built twice.
{ inputs }:
{
  overlays = [
    inputs.nix4vscode.overlays.default
    inputs.nix-vscode-extensions.overlays.default
    inputs.imap-to-jmap.overlays.default
    inputs.deepseek-harness.overlays.default
    # inputs.nur-linyinfeng.overlays.default
  ];

  config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-30.5.1" # for deltachat
    ];
  };
}
