{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware.nix
  ];

  # Automatically log in to account
  # Password already verified at startup
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.dbus}/bin/dbus-run-session -- ${lib.getExe config.programs.hyprland.package}";
        user = "inme";
      };
      default_session = initial_session;
    };
  };
}
