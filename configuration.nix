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
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
        "http://nix-serve.router.local/"
        "ssh-ng://nixos@router.local"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "router:XaQUUJ1AWd1+1JZ9CjYdMs/WoKstGyD5gD/r4gE2HQw="
      ];
    };
    daemonCPUSchedPolicy = "idle";
  };

  nixpkgs.config.allowUnfree = true;

  # Use EFI boot loader.
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 8;
    sortKey = "00-nixos";
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "UTC";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      fcitx5-configtool
    ];
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

  # Enable regreet for Wayland greeter
  programs.regreet = {
    enable = true;
    settings.GTK.theme_name = "Adwaita-dark";
  };
  services.greetd.settings.default_session.command = let
    cfg = config.programs.regreet;
  in "${pkgs.dbus}/bin/dbus-run-session -- sh -c 'XKB_DEFAULT_LAYOUT=us-qwpr ${lib.getExe pkgs.cage} ${lib.escapeShellArgs cfg.cageArgs} -- ${lib.getExe cfg.package}'";

  programs.xonsh.enable = true;

  programs.ydotool.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = pkgs.stdenv.hostPlatform.isGnu;
  hardware.sane.enable = pkgs.stdenv.hostPlatform.isGnu;

  services.power-profiles-daemon.enable = true;

  # Enable sound.
  sound.enable = false;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    # alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable bluetooth
  services.blueman.enable = true;

  # Enable touchpad support
  services.xserver.libinput = {
    enable = true;
    mouse.naturalScrolling = true;
    touchpad.tapping = true;
    touchpad.naturalScrolling = true;
  };

  services.xserver.xkb.extraLayouts.us-qwpr = {
    description = "US QWPR layout";
    languages = [ "eng" ];
    symbolsFile = xkb/symbols/us-qwpr;
  };

  # Allow swaylock to check password
  security.pam.services.swaylock = {};
  security.pam.services.gtklock = {};

  programs.dconf.enable = true;

  # Keyring management
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.xserver.windowManager.qtile = {
    enable = true;
    backend = "wayland";
  };

  # Set adb/fastboot udev rules
  services.udev.packages = [
    pkgs.android-udev-rules
  ];

  services.tailscale.enable = true;

  # Disable nscd
  services.nscd.enable = false;
  system.nssModules = lib.mkForce [];

  virtualisation.waydroid.enable = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    brightnessctl
    alsa-utils # for amixer
    wget
  ];

  # Install darling
  # Require a wrapper due to the requirement of setuid
  #security.wrappers.darling = {
  #  source = "${pkgs.darling}/bin/darling";
  #  owner = "root";
  #  group = "root";
  #  setuid = true;
  #  permissions = "u+rx,g+x,o+x";
  #};

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

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      fira-code
      fira-code-symbols
      (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
      font-awesome
    ];
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" "Noto Serif CJK SC" "Symbols Nerd Font" ];
      sansSerif = [ "Noto Sans" "Noto Sans CJK SC" "Symbols Nerd Font" ];
      monospace = [ "Fira Code Symbols" "Noto Sans Mono" "Noto Sans Mono CJK SC" "Symbols Nerd Fonts Mono" ];
    };
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

