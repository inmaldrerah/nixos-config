{ config, lib, hostName, private, ... }:

rec {
  # Use nftables backend
  networking.nftables.enable = true;

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  # networking.wireless.iwd.enable = true;

  networking.networkmanager.dns = "none";
  networking.nameservers = [ "::1" ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

  security.sudo.extraConfig = ''
    Defaults env_keep += "http_proxy https_proxy ftp_proxy rsync_proxy no_proxy"
  '';

  services.dnsmasq.enable = true;
  services.dnsmasq.settings = {
    listen-address = [ "::1" ];
    no-dhcp-interface = [ "*" ];
    cache-size = 10000;
    server = [
      "/centaur-centauri.ts.net/100.100.100.100"
      "/nju.edu.cn/210.28.129.251"
      "::1#5553"
      "223.5.5.5"
    ];
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 12345 ];
    allowedUDPPorts = [ 12345 ];
    trustedInterfaces = [ "tailscale0" "waydroid0" ];
    interfaces."wlan0".allowedUDPPorts = [ 41641 ];
    interfaces."enp1s0".allowedUDPPorts = [ 41641 ];
  };
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
