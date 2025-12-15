{ config, lib, ... }:

{

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
      "/root/.ssh"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
}
