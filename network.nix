{
  config,
  lib,
  hostName,
  private,
  ...
}:

rec {
  # Use nftables backend
  networking.nftables.enable = true;

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
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

  security.sudo-rs.extraConfig = ''
    Defaults env_keep += "http_proxy https_proxy ftp_proxy rsync_proxy no_proxy"
  '';

  services.dnsproxy.enable = true;
  services.dnsproxy.settings = {
    bootstrap = [ "https://223.5.5.5/dns-query" ];
    listen-addrs = [ "::1" ];
    listen-ports = [ 5553 ];
    upstream = [
      "[/centaur-centauri.ts.net/]100.100.100.100:53"
      "[/nju.edu.cn/]210.28.129.251:53"
      "https://dns.alidns.com/dns-query"
      "https://doh.pub/dns-query"
      "223.5.5.5:53"
    ];
    upstream-mode = "parallel";
    verbose = true;
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 12345 ];
    allowedUDPPorts = [ 12345 ];
    trustedInterfaces = [
      "lo"
      "tailscale0"
    ];
    interfaces."wlp1s0".allowedTCPPorts = [
      # Sunshine
      47984
      47989
      47990
      48010
      # Delta Chat
      45515
      45516
    ];
    interfaces."wlp1s0".allowedUDPPorts = [
      # Sunshine
      41641
      47998
      47999
      48000
      # Delta Chat
      45515
      45516
    ];
    interfaces."enp1s0".allowedUDPPorts = [ 41641 ];
  };
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
