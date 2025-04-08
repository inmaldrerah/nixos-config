{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware.nix
  ];

  # Automatically log in to account
  # Password already verified at startup
  programs.hyprland = {
    withUWSM = true;
  };
}
