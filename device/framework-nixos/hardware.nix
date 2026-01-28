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

  boot.initrd.systemd = {
    enable = true;
  };

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
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
    device = "PARTUUID=f2053f95-2ab6-49b4-851c-82122925182a";
    fsType = "btrfs";
    neededForBoot = true;
    options = [
      "subvol=nixos/nix"
      "compress=zstd:8"
    ];
    depends = [ "/" ];
  };

  fileSystems."/mnt/root" = {
    device = "PARTUUID=f2053f95-2ab6-49b4-851c-82122925182a";
    fsType = "btrfs";
    options = [ "compress=zstd:8" ];
  };

  fileSystems."/mnt/data" = {
    device = "PARTUUID=b9acc69d-7110-4095-b670-ad04e8d38a96";
    fsType = "ntfs3";
    options = [ "windows_names" ];
  };

  fileSystems."/mnt/shared" = {
    device = "/mnt/data/Shared";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/mnt/data" ];
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
    # "L+ /mnt/shared - - - - /mnt/pool/shared"
  ];
}
