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
  boot.supportedFilesystems = [ "overlay" "btrfs" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "amd_pstate=active"
  ];
  networking.hostId = "4ce220a9";

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

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/85cbadbd-85a6-420b-8534-2597d9f8da21";
    fsType = "btrfs";
    neededForBoot = true;
    depends = [ "/" ];
    options = [ "subvol=@nixos/nix,compress=zstd" ];
  };

  fileSystems."/mnt/shared" = {
    device = "/dev/disk/by-uuid/e08af0f6-084c-4e34-b2ea-918707a1d3dc";
    fsType = "btrfs";
    options = [ "compress=zstd" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/56F6-1AA8";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/b56a944d-29ba-4866-87ed-18100e4c608f";
    }
  ];

}
