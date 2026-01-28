{
  pkgs,
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

  # services.greetd = {
  #   enable = true;
  #   settings = rec {
  #     initial_session = {
  #       command = "${pkgs.uwsm}/bin/uwsm start ${pkgs.hyprland}/bin/Hyprland";
  #       user = "inme";
  #     };
  #     default_session = initial_session;
  #   };
  # };

  # Automatically log in to account
  # Password already verified at startup
  programs.hyprland = {
    withUWSM = true;
  };
}
