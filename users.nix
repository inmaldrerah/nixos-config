{ config, ... }:
let
  userconf.inme = import users.d/inme/default.nix;
in
rec {
  # Configure users
  users.mutableUsers = false;
 
  # Define a user account.
  users.users.inme = {
    isNormalUser = true;
    extraGroups = [
      "input"
      "wheel"
      "rfkill"
      "adbusers"
      "libvirtd"
      "scanner" "lp"
      "networkmanager"
    ];
  };
  
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.inme = userconf.inme.home-manager;

  environment.persistence."/nix/persist".users.inme = userconf.inme.persistence;
}
