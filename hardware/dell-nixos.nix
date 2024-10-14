# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, pkgs, lib, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [  ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.supportedFilesystems = [ "overlay" "btrfs" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';
  boot.kernelPackages = pkgs.pkgsGnu.linuxPackages_latest;
  boot.kernelParams = [
  ];
  boot.loader.systemd-boot.xbootldrMountPoint = "/xbootldr";

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.graphics.extraPackages = [  ];

  hardware.bluetooth.enable = true;

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;

  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    neededForBoot = true;
    options = [ "defaults" "size=64G" "mode=755" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1F04-28C6";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  fileSystems."/xbootldr" = {
    device = "/dev/disk/by-uuid/AE38-AB09";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  fileSystems."/nix" = { device = "/dev/disk/by-uuid/da3111a8-4051-4066-a015-ecf824b26757";
    fsType = "btrfs";
    neededForBoot = true;
    depends = [ "/" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/6188da8f-6481-43e8-8aa2-fb83d60b2e7f"; }
  ];

}
