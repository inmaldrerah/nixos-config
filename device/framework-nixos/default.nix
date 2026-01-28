{
  lib,
  ...
}:
{
  imports = [
    ./hardware.nix
  ];

  programs.regreet = {
    enable = true;
    settings.GTK.theme_name = lib.mkForce "Adwaita-dark";
  };

  programs.hyprland = {
    withUWSM = true;
  };
}
