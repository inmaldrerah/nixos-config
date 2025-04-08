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
        command = "${pkgs.uwsm}/bin/uwsm start ${lib.getExe config.programs.hyprland.package}";
        user = "inme";
      };
      default_session = initial_session;
    };
  };
}
