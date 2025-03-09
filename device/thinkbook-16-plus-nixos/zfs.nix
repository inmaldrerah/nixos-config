{ config, pkgs, lib, utils, ... }:
let
  getMount = prefix: mountPoint: (utils.escapeSystemdPath ((x: if x == "/" then x else lib.removeSuffix "/" x) (prefix + mountPoint))) + ".mount";
  getDatasetFilesystems = ds: lib.filter (x: x.fsType == "zfs" && x.device == ds) config.system.build.fileSystems;
  getDatasetMounts = prefix: ds: map (fs: getMount prefix fs.mountPoint) (getDatasetFilesystems ds);
  getDatasetDependingMounts = prefix: ds: lib.concatLists (map (fs: map (x: getMount prefix x) fs.depends) (getDatasetFilesystems ds));

  zfsCmd = "${config.boot.zfs.package}/sbin/zfs";

  datasets = lib.unique (map (x: x.device) (lib.filter (x: x.fsType == "zfs") config.system.build.fileSystems));
  datasetsNeededForBoot = lib.unique (map (x: x.device) (lib.filter (x: x.fsType == "zfs" && x.neededForBoot) config.system.build.fileSystems));

  createDecryptService = { ds, systemd, prefix ? "" }: lib.nameValuePair "zfs-decrypt-${utils.escapeSystemdPath ds}" {
    description = "Decrypt ZFS dataset ${ds}";
    requires = [
      "zfs-import.target"
    ] ++ (getDatasetDependingMounts prefix ds);
    after = [
      "zfs-import.target"
    ] ++ (getDatasetDependingMounts prefix ds);
    requiredBy = getDatasetMounts prefix ds;
    before = [
      "shutdown.target"
    ] ++ (getDatasetMounts prefix ds);
    conflicts = [ "shutdown.target" ];
    unitConfig = {
      DefaultDependencies = "no";
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${zfsCmd} list -Ho keylocation,keystatus -t volume,filesystem ${ds} | while IFS=$'\t' read -r kl ks; do
        {
          if [[ "$ks" != unavailable ]]; then
            continue
          fi
          case "$kl" in
            none )
              ;;
            prompt )
              tries=3
              success=false
              while [[ $success != true ]] && [[ $tries -gt 0 ]]; do
                ${systemd}/bin/systemd-ask-password --timeout=${toString config.boot.zfs.passwordTimeout} "Enter key for ${ds}:" | ${zfsCmd} load-key "${ds}" \
                  && success=true \
                  || tries=$((tries - 1))
              done
              [[ $success = true ]]
              ;;
            * )
              if [[ "$kl" == file://* ]]; then
                ${zfsCmd} load-key -L "file://${prefix}''${kl#file://}" "${ds}"
              else
                ${zfsCmd} load-key "${ds}"
              fi
              ;;
          easc
        } < /dev/null
      done
    '';
  };
in {
  boot.initrd.systemd = {
    services = lib.listToAttrs (map (ds: createDecryptService {
      inherit ds;
      systemd = config.boot.initrd.systemd.package;
      prefix = "/sysroot";
    }) datasetsNeededForBoot);
  };
  systemd.services = lib.listToAttrs (map (ds: createDecryptService {
    inherit ds;
    systemd = config.systemd.package;
  }) datasets);
}
