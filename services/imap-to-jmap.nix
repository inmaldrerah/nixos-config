{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.imap-to-jmap;
  dataDir = "/var/lib/imap-to-jmap";

  # Self-signed localhost cert; acceptable for a loopback-only bridge (Thunderbird
  # will warn once and can be told to always trust it).
  cert = pkgs.runCommand "imap-to-jmap-cert" {
    nativeBuildInputs = [ pkgs.openssl ];
  } ''
    mkdir -p "$out"
    ${lib.getExe pkgs.openssl} req -x509 -newkey rsa:2048 \
      -keyout "$out/imap.key" -out "$out/imap.crt" -days 3650 -nodes \
      -subj "/CN=${cfg.tlsName}" \
      -addext "subjectAltName=DNS:${cfg.tlsName},IP:127.0.0.1"
  '';

  configFile = pkgs.writeText "imap-to-jmap.yml" ''
    bind-addr: ${cfg.bind}
    bind-port: ${toString cfg.port}
    bind-port-tls: ${toString cfg.portTls}
    log-level: debug
    jmap-url: ${cfg.jmapUrl}
    jmap-trusted-hosts: ${cfg.trustedHosts}
    cache-dir: ${dataDir}
    cache-purge-every: 0 3 *
    cache-removed-id-ttl: 2592000
    cert-path: ${cert}/imap.crt
    key-path: ${cert}/imap.key
    name-shared: Shared Folders
    name-all: All Mail
    max-request-size: 52428800
  '';
in
{
  options.services.imap-to-jmap = {
    enable = lib.mkEnableOption "IMAP-to-JMAP proxy for a Mailbux account";

    bind = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Local address to bind the IMAP listener on.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 1143;
      description = "Plaintext IMAP port (supports STARTTLS).";
    };

    portTls = lib.mkOption {
      type = lib.types.port;
      default = 1993;
      description = "Implicit-TLS IMAP port.";
    };

    jmapUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://my.mailbux.com";
      description = "Upstream JMAP session endpoint.";
    };

    trustedHosts = lib.mkOption {
      type = lib.types.str;
      default = "my.mailbux.com";
      description = "Backend host(s) allowed for JMAP redirects (semicolon separated).";
    };

    tlsName = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
      description = "Common name on the generated self-signed TLS certificate.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.imap-to-jmap = {
      description = "IMAP-to-JMAP proxy";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.stalwart-imap-proxy} --config=${configFile}";
        DynamicUser = true;
        StateDirectory = "imap-to-jmap";
        Restart = "on-failure";
        RestartSec = 5;
        UMask = "0077";
      };
    };
  };
}
