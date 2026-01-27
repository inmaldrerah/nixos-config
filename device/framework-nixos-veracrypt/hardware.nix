{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usb_storage"
    "sd_mod"
    "sdhci_pci"
  ];
  boot.initrd.kernelModules = [
    "amdgpu"
    # crypto related modules
    "dm_mod"
    "dm_crypt"
    "aes"
    "aes_generic"
    "blowfish"
    "twofish"
    "serpent"
    "cbc"
    "xts"
    "lrw"
    "sha1"
    "sha256"
    "af_alg"
    "algif_skcipher"
    "cryptd"
    "input_leds"
    "ecb"
  ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.supportedFilesystems = [
    "overlay"
    "btrfs"
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    options kvm-amd nested=1
  '';
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "amd_pstate=active"
  ];
  networking.hostId = "4ce220a9";

  boot.initrd.systemd =
    let
      systemdPkg = config.boot.initrd.systemd.package;
    in
    {
      enable = true;
      # initrdBin = [
      #   pkgs.veracrypt
      # ];
      # contents."/etc/crypttab".source = pkgs.writeText "initrd-crypttab" ''
      #   ROOT /dev/disk/by-partuuid/a52a6915-6021-47bd-9685-bc138e5f127c - tcrypt,tcrypt-veracrypt
      # '';
      # extraBin.systemd-cryptsetup = "${systemdPkg}/bin/systemd-cryptsetup";
      # additionalUpstreamUnits = [
      #   "cryptsetup-pre.target"
      #   "cryptsetup.target"
      #   "remote-cryptsetup.target"
      # ];
      # storePaths = [
      #   "${systemdPkg}/bin/systemd-cryptsetup"
      #   "${systemdPkg}/lib/systemd/system-generators/systemd-cryptsetup-generator"
      # ];
    };

  # services.lvm.enable = true;
  # boot.initrd.services.lvm.enable = true;

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.graphics.extraPackages = [
    # pkgs.rocmPackages.clr.icd # for OpenCL support
  ];
  hardware.graphics.extraPackages32 = [
  ];
  hardware.amdgpu.initrd.enable = true;

  hardware.bluetooth.enable = true;

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;

  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    neededForBoot = true;
    options = [
      "defaults"
      "size=64G"
      "mode=755"
    ];
  };

  fileSystems."/nix" = {
    # device = "/dev/mapper/ROOT";
    device = "PARTUUID=a52a6915-6021-47bd-9685-bc138e5f127c";
    fsType = "btrfs";
    neededForBoot = true;
    options = [
      "subvol=nixos/nix"
      "compress=zstd:8"
    ];
    depends = [ "/" ];
  };

  fileSystems."/mnt/pool" = {
    device = "PARTUUID=a52a6915-6021-47bd-9685-bc138e5f127c";
    fsType = "btrfs";
    options = [ "compress=zstd:8" ];
    depends = [ "/" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/889D-C417";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/2dec9ec9-8ea9-4cb7-8250-dd1fd9757614";
    }
  ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  systemd.tmpfiles.rules = [
    "L+ /mnt/shared - - - - /mnt/pool/shared"
  ];
}
