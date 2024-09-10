{ config, lib, ... }:

{
  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    neededForBoot = true;
    options = [ "defaults" "size=64G" "mode=755" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1F04-28C6";
    fsType = "vfat";
  };

  fileSystems."/nix" = { device = "/dev/disk/by-uuid/da3111a8-4051-4066-a015-ecf824b26757";
    fsType = "btrfs";
    neededForBoot = true;
    depends = [ "/" ];
  };

  fileSystems."/home/inme/.local/share/waydroid/data/media/0/Share" = {
    device = "/home/inme/Share/Waydroid";
    fsType = "none";
    options = [ "bind" "user" "noauto" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/6188da8f-6481-43e8-8aa2-fb83d60b2e7f"; }
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
      "/var/lib/nixos"
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
