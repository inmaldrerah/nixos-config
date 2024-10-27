# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, pkgs, lib, modulesPath, ... }:
let
  isUnstable = config.boot.zfs.package == pkgs.zfsUnstable;
  zfsCompatibleKernelPackages = lib.filterAttrs (
    name: kernelPackages:
    (builtins.match "linux_[0-9]+_[0-9]+" name) != null
    && (builtins.tryEval kernelPackages).success
    && (
      (!isUnstable && !kernelPackages.zfs.meta.broken)
      || (isUnstable && !kernelPackages.zfs_unstable.meta.broken)
    )
  ) pkgs.pkgsGnu.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in
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
  boot.kernelPackages = latestKernelPackage; # pkgs.pkgsGnu.linuxPackages_latest;
  boot.kernelParams = [
    "amd_pstate=active"
  ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "4ce220a9";

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.graphics.extraPackages = [ pkgs.rocmPackages.clr.icd ];
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
    device = "shared/root";
    fsType = "zfs";
    options = [ "zfsutil" "nofail" ];
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

  environment.persistence."/nix/persist".files = [
    "/etc/zfs/zpool.cache"
  ];

}
