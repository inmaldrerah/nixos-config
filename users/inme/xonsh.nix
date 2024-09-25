{ config, pkgs, ... }:
{
  programs.xonsh = {
    enable = true;
    rcFiles."nix-helper.xsh".text = ''
      def __nix_helper_init():
        def __rebuild_system_local(args):
          return ![nixos-rebuild -v --use-remote-sudo --flake /etc/nixos @(args)]
        
        def __rebuild_system_remote(args):
          substituters = tuple(map(lambda s: s[len("trusted-substituters = "):], filter(lambda s: s.startswith("trusted-substituters = "), p"/etc/nix/nix.conf".read_text().split("\n"))))[0]
          return ![nixos-rebuild -j0 -v --option substituters @(substituters) --builders ssh://nixos@router.local --use-remote-sudo --flake /etc/nixos @(args)]
        
        def __commit_nixos_config(args):
          current_pwd = $PWD
          $[cd /etc/nixos]
          $[git add .]
          $[git commit -m @("snapshot@{}".format(str($(date -u +%m/%d/%Y-%T)).strip()))]
          $[cd @(current_pwd)]
       
        def __rebuild_system(args):
          __commit_nixos_config(args)
          home = $HOME
          if pf"{home}/.nix-local".is_file():
            return __rebuild_system_local(args)
          else:
            status = !(curl http://nix-serve.router.local/ --noproxy nix-serve.router.local --connect-timeout 1)
            if not status:
              return __rebuild_system_local(args)
            else:
              return __rebuild_system_remote(args)
        
        def rebuild_system(args):
          rebuild_status = __rebuild_system(args)
          if any(map(lambda x: x in args, ["switch", "boot"])):
            target = $(sudo cat /boot/loader/loader.conf).split()[3]
            print(f"setting default to @saved and oneshot to {target}")
            ![sudo bootctl set-default "@saved"] && \
              ![sudo bootctl set-oneshot @(target)]
          return rebuild_status
        
        def toggle_nix_local(args):
          if "HOME" in ''${...} and $HOME != "":
            home = $HOME
            if pf"{home}/.nix-local".is_file():
              $[rm f"{home}/.nix-local"]
            else:
              $[touch f"{home}/.nix-local"]
        
        aliases["rebuild-system"] = rebuild_system
        aliases["toggle-nix-local"] = toggle_nix_local
      
      __nix_helper_init()
      del __nix_helper_init
    '';
    extraConfig = ''
      def __env_setup():
        user = $USER
        if not ''${...}.get(f"__USER_{user}_SETUP_DONE"):
          home = $HOME
          $PATH.insert(0, f"{home}/.local/bin")
          $TERM = "xterm-256color"
          ''${f"__USER_{user}_SETUP_DONE"} = "1"

      __env_setup()
      del __env_setup
    '';
  };
}
