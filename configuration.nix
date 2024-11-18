# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, nixpkgsInput, ... }:

rec {
  nix = {
    nixPath = [ "nixpkgs=${nixpkgsInput}" ];
    package = pkgs.nixVersions.stable;
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
    };
    daemonCPUSchedPolicy = "idle";
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-30.5.1" # for deltachat
  ];

  system.switch.enable = false;
  system.switch.enableNg = true;

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
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-rime
        fcitx5-configtool
      ];
      waylandFrontend = true;
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

  programs.command-not-found.enable = false;

  # Enable regreet for Wayland greeter
  programs.regreet = {
    enable = true;
    settings.GTK.theme_name = lib.mkForce "Adwaita-dark";
  };
  services.greetd.settings.default_session.command = let
    cfg = config.programs.regreet;
  # in "${pkgs.dbus}/bin/dbus-run-session -- sh -c 'XKB_DEFAULT_LAYOUT=us-qwpr ${lib.getExe pkgs.cage} ${lib.escapeShellArgs cfg.cageArgs} -- ${lib.getExe cfg.package}'";
  in "${pkgs.dbus}/bin/dbus-run-session -- sh -c '${lib.getExe pkgs.cage} ${lib.escapeShellArgs cfg.cageArgs} -- ${lib.getExe cfg.package}'";

  programs.xonsh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = pkgs.stdenv.hostPlatform.isGnu;
  hardware.sane.enable = pkgs.stdenv.hostPlatform.isGnu;

  services.power-profiles-daemon.enable = true;

  # Enable sound.
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
  services.libinput = {
    enable = true;
    mouse.naturalScrolling = true;
    touchpad.tapping = true;
    touchpad.naturalScrolling = true;
  };

  # Allow swaylock to check password
  security.pam.services.swaylock = {};
  security.pam.services.gtklock = {};

  # For OBS virtual camera
  security.polkit.enable = true;

  programs.dconf.enable = true;

  # Keyring management
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  programs.nix-ld.enable = true;

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

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  # Disable nscd
  services.nscd.enable = false;
  system.nssModules = lib.mkForce [];

  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # virtualisation.waydroid.enable = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    neovim # make sure other users have this
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

  fonts = {
    packages = with pkgs; [
      source-sans
      source-serif
      source-code-pro
      source-han-sans
      source-han-serif
      source-han-mono
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
      monospace = [ "Fira Code" "Noto Sans Mono" "Noto Sans Mono CJK SC" "Symbols Nerd Fonts Mono" ];
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

