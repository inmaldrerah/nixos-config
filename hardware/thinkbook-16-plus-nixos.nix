# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, pkgs, lib, modulesPath, ... }:
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.supportedFilesystems = [ "overlay" "btrfs" "zfs" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';
  boot.kernelPackages = pkgs.linuxPackages;
  boot.kernelParams = [
    "amd_pstate=active"
  ];
  networking.hostId = "4ce220a9";

  boot.zfs.requestEncryptionCredentials = [];

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.services = let
      zfsCmd = "${config.boot.zfs.package}/sbin/zfs";
      askPasswd = "${config.boot.initrd.systemd.package}/bin/systemd-ask-password";
  in {
    zfs-unlock-zpool-keys = {
      wants = [
        "zfs-import-zpool.service"
        "-.mount"
      ];
      after = [
        "zfs-import-zpool.service"
        "-.mount"
      ];
      requiredBy = [
        "mnt-keys.mount"
      ];
      before = [
        "mnt-keys.mount"
        "shutdown.target"
      ];
      conflicts = [ "shutdown.target" ];
      unitConfig = {
        DefaultDependencies = "no";
      };
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${askPasswd} --timeout=${toString config.boot.zfs.passwordTimeout} "Enter key for zpool/keys:" | ${zfsCmd} load-key "zpool/keys"
      '';
    };
    zfs-unlock-zpool-nixos = {
      wants = [
        "zfs-import-zpool.service"
        "mnt-keys.mount"
      ];
      after = [
        "zfs-import-zpool.service"
        "mnt-keys.mount"
      ];
      requiredBy = [
        "nix.mount"
      ];
      before = [
        "nix.mount"
        "shutdown.target"
      ];
      conflicts = [ "shutdown.target" ];
      unitConfig = {
        DefaultDependencies = "no";
      };
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${zfsCmd} load-key "zpool/nixos"
      '';
    };
  };

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.graphics.extraPackages = [
    pkgs.amdvlk # for Vulkan
    # pkgs.rocmPackages.clr.icd # for OpenCL support
  ];
  hardware.graphics.extraPackages32 = [
    pkgs.driversi686Linux.amdvlk # for Vulkan
  ];
  hardware.amdgpu.initrd.enable = true;

  hardware.bluetooth.enable = true;

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;

  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    neededForBoot = true;
    options = [ "defaults" "size=64G" "mode=755" ];
  };

  fileSystems."/mnt/keys" = {
    device = "zpool/keys";
    fsType = "zfs";
    neededForBoot = true;
    depends = [ "/" ];
  };

  fileSystems."/nix" = {
    device = "zpool/nixos";
    fsType = "zfs";
    neededForBoot = true;
    depends = [ "/mnt/keys" ];
  };

  fileSystems."/mnt/shared" = {
    device = "/dev/disk/by-uuid/e08af0f6-084c-4e34-b2ea-918707a1d3dc";
    fsType = "btrfs";
    options = [ "compress=zstd" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/889D-C417";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/b56a944d-29ba-4866-87ed-18100e4c608f";
    }
  ];

}
