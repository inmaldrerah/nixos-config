{ config, pkgs, lib, ... }@args:
let
  userconf.inme = import ./inme args;
in
rec {
  # Configure users
  users.mutableUsers = false;
 
  # For testing purpose only
  users.users.root.password = "rootpasswd";
  users.users.inme.password = "passwd";

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

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.inme = userconf.inme.home-manager;
  home-manager.users.root = { pkgs, ... }: {
    home.stateVersion = "22.11";
  };
}
