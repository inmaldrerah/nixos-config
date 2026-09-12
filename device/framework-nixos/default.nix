{
  lib,
  ...
}:
{
  imports = [
    ./hardware.nix
  ];

  services.displayManager.regreet = {
    enable = true;
    settings.GTK.theme_name = lib.mkForce "Adwaita-dark";
  };
}
