{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware.nix
  ];

  boot.loader.systemd-boot.extraEntries."freebsd.conf" = ''
    title FreeBSD Boot Loader
    efi /EFI/freebsd/loader.efi
    sort-key z_freebsd
  '';

  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.uwsm}/bin/uwsm start ${pkgs.hyprland}/bin/Hyprland";
        user = "inme";
      };
      default_session = initial_session;
    };
  };

  # Automatically log in to account
  # Password already verified at startup
  programs.hyprland = {
    withUWSM = true;
  };
}
