{ inputs, ... }:
{
  nixpkgs.overlays = [
    inputs.imap-to-jmap.overlays.default
  ];

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-30.5.1" # for deltachat
    ];
  };
}
