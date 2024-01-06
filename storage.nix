{ config, lib, ... }:

{
  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "defaults" "size=64G" "mode=755" ];
  };

  fileSystems."/mnt/root" = {
    device = "/dev/disk/by-uuid/922264b4-c192-4b3b-8e5d-a4c902c002eb";
    fsType = "bcachefs";
    neededForBoot = true;
    options = [ "compression=zstd" ];
  };

  fileSystems."/nix" = {
    device = "/mnt/root/@nixos";
    fsType = "none";
    options = [ "bind" ];
  };

  fileSystems."/mnt/shared" = {
    device = "/dev/disk/by-uuid/4b501aec-8608-486f-a51c-d5af4312c8b1";
    fsType = "btrfs";
    options = [ "nofail" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/56F6-1AA8";
    fsType = "vfat";
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/b56a944d-29ba-4866-87ed-18100e4c608f";
    }
  ];

  # Enable persistent storage
  environment.persistence."/nix/persist" = {
    directories = [
      "/etc/nixos"
      "/etc/NetworkManager/system-connections"
      "/var/cache"
      "/var/log"
      "/var/lib/iwd"
      "/var/lib/libvirt"
      "/var/lib/systemd"
      "/var/lib/tailscale"
      "/root/.ssh"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
}
