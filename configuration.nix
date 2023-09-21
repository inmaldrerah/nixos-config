# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

rec {
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
      keep-going = true
    '';
    settings.extra-sandbox-paths = [ config.programs.ccache.cacheDir ];
    daemonCPUSchedPolicy = "idle";
  };

  programs.ccache = {
    enable = true;
    cacheDir = "/nix/ccache";
  };

  # Use EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };

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

  # Enable greetd for Wayland greeter
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
      	command = "${pkgs.cage}/bin/cage -s -- ${pkgs.greetd.gtkgreet}/bin/gtkgreet";
      };
    };
  };

  environment.etc."greetd/environments".text = ''
    Hyprland
    bash
  '';

  # Enable CUPS to print documents.
  services.printing.enable = pkgs.stdenv.hostPlatform.isGnu;
  hardware.sane.enable = pkgs.stdenv.hostPlatform.isGnu;

  services.tlp.enable = true;

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

  # Allow swaylock to check password
  security.pam.services.swaylock = {};

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  # Keyring management
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    enableNvidiaPatches = false;
  };

  # Set adb/fastboot udev rules
  services.udev.packages = [
    pkgs.android-udev-rules
  ];

  # Disable nscd
  services.nscd.enable = false;
  system.nssModules = lib.mkForce [];

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    brightnessctl
    # virt-manager
    alsa-utils # for amixer
    neovim
    wget
  ];

  environment.variables = {
    EDITOR = "nvim";
    HTTP_PROXY = "http://localhost:1081";
    HTTPS_PROXY = "http://localhost:1081";
    FTP_PROXY = "http://localhost:1081";
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
    ] ++ [ # Default font packages except noto-fonts-emoji
      dejavu_fonts
      freefont_ttf
      gyre-fonts # TrueType substitutes for standard PostScript fonts
      liberation_ttf
      unifont
    ];
    enableDefaultPackages = false;
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" "Noto Serif CJK SC" ];
      sansSerif = [ "Noto Sans" "Noto Sans CJK SC" ];
      monospace = [ "Fira Code" "Fira Code Symbols" "Noto Sans Mono" "Noto Sans Mono CJK SC" ];
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

