{ config, lib, ... }:

{
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
    device = "/dev/disk/by-uuid/4b501aec-8608-486f-a51c-d5af4312c8b1";
    fsType = "btrfs";
    neededForBoot = true;
    depends = [ "/" ];
    options = [ "nofail" ];
  };

  fileSystems."/home/inme/.local/share/waydroid/data/media/0/Share" = {
    device = "/home/inme/Share/Waydroid";
    fsType = "none";
    options = [ "bind" "user" "noauto" ];
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
      "/var/lib/waydroid"
      "/root/.ssh"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
}
