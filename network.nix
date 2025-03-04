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

  services.dnsproxy.enable = true;
  services.dnsproxy.settings = {
    bootstrap = [ "https://223.5.5.5/dns-query" ];
    listen-addrs = [ "127.0.0.1" ];
    listen-ports = [ 5553 ];
    upstream = [
      "[/centaur-centauri.ts.net/]100.100.100.100:53"
      "[/nju.edu.cn/]210.28.129.251:53"
      "[/nju.edu.cn/]https://223.5.5.5/dns-query"
      "[/cn/]https://223.5.5.5/dns-query"
      "https://1.1.1.1/dns-query"
    ];
    upstream-mode = "parallel";
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 12345 ];
    allowedUDPPorts = [ 12345 ];
    trustedInterfaces = [ "tailscale0" ];
    interfaces."wlan0".allowedUDPPorts = [ 41641 ];
    interfaces."enp1s0".allowedUDPPorts = [ 41641 ];
  };
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
