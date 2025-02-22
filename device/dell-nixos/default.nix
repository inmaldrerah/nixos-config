{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware.nix
  ];

  # Enable regreet for Wayland greeter
  programs.regreet = {
    enable = true;
    settings.GTK.theme_name = lib.mkForce "Adwaita-dark";
  };
  # services.greetd.settings.default_session.command = let
  #   cfg = config.programs.regreet;
  # in "${pkgs.dbus}/bin/dbus-run-session -- sh -c '${lib.getExe pkgs.cage} ${lib.escapeShellArgs cfg.cageArgs} -- ${lib.getExe cfg.package}'";
}
