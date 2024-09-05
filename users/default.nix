{ config, pkgs, nixvim, ... }@args:
let
  userconf.inme = import inme/default.nix args;
in
rec {
  # Configure users
  users.mutableUsers = false;
 
  # Define a user account.
  users.users.inme = {
    isNormalUser = true;
    extraGroups = [
      "lp"
      "input"
      "wheel"
      "rfkill"
      "scanner"
      "adbusers"
      "libvirtd"
      "networkmanager"
    ];
    shell = userconf.inme.shell;
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.inme = userconf.inme.home-manager;
  home-manager.users.root = { pkgs, ... }: {
    home.stateVersion = "22.11";
    gtk = {
      enable = true;
      theme.name = "Adwaita-dark";
      theme.package = pkgs.gnome-themes-extra;
    };
  };

  environment.persistence."/nix/persist".users.inme = userconf.inme.persistence;
  environment.persistence."/mnt/shared/linux-home/nixos".users.inme = userconf.inme.shared-persistence;
}
