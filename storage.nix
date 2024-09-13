{ config, lib, ... }:

{
  fileSystems."/home/inme/.local/share/waydroid/data/media/0/Share" = {
    device = "/home/inme/Share/Waydroid";
    fsType = "none";
    options = [ "bind" "user" "noauto" ];
  };

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
