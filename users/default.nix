{ config, ... }:
let
  userconf.inme = import inme/default.nix;
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
  home-manager.users.root = { pkgs, ... }: {
    home.stateVersion = "22.11";
    gtk = {
      enable = true;
      theme.name = "Adwaita-dark";
      theme.package = pkgs.gnome.gnome-themes-extra;
    };
  };

  environment.persistence."/nix/persist".users.inme = userconf.inme.persistence;
}
