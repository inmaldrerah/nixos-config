{
  config,
  pkgs,
  inputs,
  ...
}@args:
let
  userconf.inme = import ./inme args;
in
{
  # Configure users
  users.mutableUsers = false;

  # Define a user account.
  users.users.inme = {
    isNormalUser = true;
    extraGroups = [
      "lp"
      "input"
      "wheel"
      "docker"
      "rfkill"
      "scanner"
      "adbusers"
      "libvirtd"
      "networkmanager"
    ];
    shell = userconf.inme.shell;
  };

  # inme's home-manager config lives in ~/.config/home-manager but is
  # activated through the NixOS HM module. It reaches eval through the
  # locked `home-config-inme` flake input (see flake.nix), so changes apply
  # once rebuild_system refreshes that input.
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.inme = inputs.home-config-inme.homeModules.default;
  home-manager.users.root =
    { pkgs, ... }:
    {
      home.stateVersion = "22.11";
      gtk = rec {
        enable = true;
        theme.name = "Adwaita-dark";
        theme.package = pkgs.gnome-themes-extra;
        gtk4.theme = theme;
      };
    };

  environment.persistence."/mnt/shared/linux-home/nixos".users.inme =
    userconf.inme.shared-persistence;
}
