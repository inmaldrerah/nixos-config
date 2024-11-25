{ config, pkgs, ... }:
{
  programs.xonsh = {
    enable = true;
    rcFiles."nix-helper.xsh".text = ''
      def __nix_helper_init():
        def __rebuild_system_local(args):
          return ![nixos-rebuild -v --use-remote-sudo --flake /etc/nixos --impure @(args)]
        
        def __commit_nixos_config():
          current_pwd = $PWD
          $[cd /etc/nixos]
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
          if any(map(lambda x: x in args, ["switch", "boot"])):
            target = $(sudo cat /boot/loader/loader.conf).split()[3]
            print(f"setting default to @saved and oneshot to {target}")
            ![sudo bootctl set-default "@saved"] && \
              ![sudo bootctl set-oneshot @(target)]
          return rebuild_status
        
        aliases["rebuild-system"] = rebuild_system
      
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
