# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

rec {
  nix = {
    package = pkgs.nixFlakes;
    buildMachines = [{
      hostName = "router.local";
      systems = [
        "x86_64-linux"
      ];
      protocol = "ssh";
      sshUser = "nixos";
      maxJobs = 36;
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }];
    distributedBuilds = true;
    settings = {
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      keep-outputs = true;
      keep-derivations = true;
      keep-going = true;
      builders-use-substitutes = true;
      substituters = [
        "https://cache.lix.systems"
        "https://nix-community.cachix.org"
        "https://daeuniverse.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-substituters = [
        "https://cache.lix.systems"
        "https://nix-community.cachix.org"
        "https://daeuniverse.cachix.org"
        "https://cache.nixos.org/"
        "http://nix-serve.router.local/"
        "ssh-ng://nixos@router.local"
      ];
      trusted-public-keys = [
        "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "daeuniverse.cachix.org-1:8hRIzkQmAKxeuYY3c/W1I7QbZimYphiPX/E7epYNTeM="
        "router:XaQUUJ1AWd1+1JZ9CjYdMs/WoKstGyD5gD/r4gE2HQw="
      ];
    };
    daemonCPUSchedPolicy = "idle";
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
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-rime
        fcitx5-configtool
      ];
      # waylandFrontend = true;
    };
  };

  # Fake glibc locales package
  i18n.glibcLocales = if pkgs.stdenv.hostPlatform.isGnu
    then pkgs.glibcLocales
    else pkgs.stdenv.mkDerivation {
      name = "empty";
      dontUnpack = true;
      installPhase = "touch $out";
      version = "0.0";
    };

  programs.xonsh.enable = true;

  # Enable touchpad support
  services.libinput = {
    enable = true;
    mouse.naturalScrolling = true;
    touchpad.tapping = true;
    touchpad.naturalScrolling = true;
  };

  # Allow swaylock to check password
  security.pam.services.swaylock = {};
  security.pam.services.gtklock = {};

  services.xserver.xkb.extraLayouts = {
    us-qwpr = {
      description = "US QWPR layout";
      languages = [ "eng" ];
      symbolsFile = xkb/symbols/us-qwpr;
    };
    us-custom = {
      description = "US Custom layout";
      languages = [ "eng" ];
      symbolsFile = xkb/symbols/us-custom;
    };
  };

# Set adb/fastboot udev rules
  services.udev.packages = [
    pkgs.android-udev-rules
  ];

  services.tailscale.enable = true;

  # Disable nscd
  services.nscd.enable = false;
  system.nssModules = lib.mkForce [];

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    brightnessctl
    alsa-utils # for amixer
    wget
  ];

  environment.variables = {
    TERMINAL = "alacritty";
    EDITOR = "nvim";
    HTTP_PROXY = "http://localhost:1081";
    HTTPS_PROXY = "http://localhost:1081";
    FTP_PROXY = "http://localhost:1081";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

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

