{ config, pkgs, ... }@args:
rec {
  # Configure users
  users.mutableUsers = false;

  users.users.root.initialPassword = "rootPassword";

  # Define a user account.
  users.users.user = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    initialPassword = "userPassword";
  };
  
}
