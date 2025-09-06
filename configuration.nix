# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, nixpkgsInput, ... }:

rec {
  nix = {
    nixPath = [ "nixpkgs=${nixpkgsInput}" ];
    package = pkgs.lixPackageSets.latest.lix;
    # package = pkgs.nixVersions.latest;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      keep-outputs = true;
      keep-derivations = true;
      keep-going = true;
      builders-use-substitutes = true;
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.garnix.io"
        "https://cache.nixos.org"
      ];
      trusted-substituters = [
        "https://nix-community.cachix.org"
        "https://cache.garnix.io"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
      # pasta-path = "";
    };
    daemonCPUSchedPolicy = "idle";
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  # Use EFI boot loader.
  boot.loader.systemd-boot = {
    enable = true;
    # configurationLimit = 8;
    sortKey = "00-nixos";
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "UTC";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Fake glibc locales package
  i18n.glibcLocales = pkgs.glibcLocales;
  programs.command-not-found.enable = false;

  services.power-profiles-daemon.enable = true;

  # For OBS virtual camera
  security.polkit.enable = true;

  security.sudo.enable = false;
  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
  };
  security.pam.services.systemd-run0 = {};

  programs.dconf.enable = true;

  programs.nix-ld.enable = true;

  # Disable nscd
  services.nscd.enable = false;
  system.nssModules = lib.mkForce [];

  services.upower.enable = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    neovim # make sure other users have this
    alsa-utils # for amixer
    wget
  ];

  environment.variables = {
    EDITOR = "nvim";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      fira-code
      nerd-fonts.symbols-only
      font-awesome
    ];
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" "Symbols Nerd Font" ];
      sansSerif = [ "Noto Sans" "Symbols Nerd Font" ];
      monospace = [ "Fira Code" "Noto Sans Mono" "Symbols Nerd Fonts Mono" ];
    };
  };

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It’s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}

