{ config, pkgs, ... }:
{
  programs.xonsh = {
    enable = true;
    rcFiles."nix-helper.xsh".text = ''
      if $XONSH_INTERACTIVE:
        def __nix_helper_init():
          def __rebuild_system_local(args):
            return ![nixos-rebuild -v --sudo --flake /etc/nixos --impure @(args)]
          
          def __commit_nixos_config():
            current_pwd = $PWD
            $[cd /etc/nixos]
            $[git add .]
            $[git commit -m @("snapshot@{}".format(str($(date -u +%m/%d/%Y-%T)).strip()))]
            $[cd /etc/nixos/private]
            $[git add .]
            $[git commit -m @("snapshot@{}".format(str($(date -u +%m/%d/%Y-%T)).strip()))]
            $[cd @(current_pwd)]
          
          def __update_system():
            $[nix flake update --flake "/etc/nixos"]
            $[nix flake update --flake "path:/etc/nixos/private"]
          
          def __rebuild_system(args):
            if "--update" in args:
              __update_system()
              args.remove("--update")
            __commit_nixos_config()
            return __rebuild_system_local(args)
          
          def rebuild_system(args):
            rebuild_status = __rebuild_system(args)
            orig_askpass = None
            if "SUDO_ASKPASS" in ''${...}:
              orig_askpass = $SUDO_ASKPASS
              del $SUDO_ASKPASS
            if any(map(lambda x: x in args, ["switch", "boot"])):
              target = $(sudo cat /boot/loader/loader.conf).split()[3]
              print(f"setting default to @saved and oneshot to {target}")
              ![sudo bootctl set-default "@saved"] && \
                ![sudo bootctl set-oneshot @(target)]
            if orig_askpass is not None:
              $SUDO_ASKPASS = orig_askpass
            return rebuild_status
          
          aliases["rebuild-system"] = rebuild_system
        
        __nix_helper_init()
        del __nix_helper_init
    '';
    extraConfig = ''
      if $XONSH_INTERACTIVE:
        def __env_setup():
          user = $USER
          if not ''${...}.get(f"__USER_{user}_SETUP_DONE"):
            home = $HOME
            $PATH.insert(0, f"{home}/.local/bin")
            $TERM = "xterm-256color"
            ''${f"__USER_{user}_SETUP_DONE"} = True
          import xonsh
          if len(xonsh.xontribs.xontribs_loaded()) == 0:
            if len(xonsh.xontribs.get_xontribs()) == 1: # only coreutils
              ![xonsh]
              ![exit]
            else:
              xontrib load coreutils
              xontrib load direnv
              xontrib load fish_completer

        __env_setup()
        del __env_setup
    '';
    extraPackages = ps: [
      ps.xonsh.xontribs.xonsh-direnv
      ps.xonsh.xontribs.xontrib-fish-completer
    ];
  };
}
