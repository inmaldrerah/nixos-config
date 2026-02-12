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
    ];
    interfaces."wlp1s0".allowedUDPPorts = [
      # Sunshine
      41641
      47998
      47999
      48000
    ];
    interfaces."enp1s0".allowedUDPPorts = [ 41641 ];
  };
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
