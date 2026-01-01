{
  lib,
  ...
}:
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
    extraConfig = lib.mkBefore ''
      if $XONSH_INTERACTIVE:
        def __env_setup():
          user = $USER
          if not ''${...}.get(f"__USER_{user}_SETUP_DONE"):
            home = $HOME
            $PATH.insert(0, f"{home}/.local/bin")
            ''${f"__USER_{user}_SETUP_DONE"} = True
            $_ZO_RESOLVE_SYMLINKS = "1"

            @events.on_transform_command
            def pl_rewrite(cmd: str):
              return __xonsh__.imp.re.sub(r"|>\s+((?:\|\||[^|])+)", r"| pl @(py!(\1)) ", cmd)

        __env_setup()
        del __env_setup

        def py(code: str):
          return code
    '';
    extraPackages = (
      ps: [
        ps.xonsh.xontribs.xonsh-direnv
        ps.xonsh.xontribs.xontrib-fish-completer
        (ps.callPackage (
          {
            buildPythonPackage,
            fetchFromGitHub,
            setuptools,
            writableTmpDirAsHomeHook,
            xonsh,
            nix-update-script,
            lib,
            ...
          }:
          buildPythonPackage rec {
            pname = "xontrib-sh";
            version = "0.3.1";
            format = "setuptools";

            src = fetchFromGitHub {
              owner = "anki-code";
              repo = "xontrib-sh";
              tag = version;
              hash = "sha256-KL/AxcsvjxqxvjDlf1axitgME3T+iyuW6OFb1foRzN8=";
            };

            build-system = [
              setuptools
            ];

            nativeCheckInputs = [
              writableTmpDirAsHomeHook
              xonsh
            ];

            passthru.updateScript = nix-update-script { };

            meta = {
              description = "Paste and run commands from bash, zsh, fish, tcsh, pwsh in xonsh shell";
              homepage = "https://github.com/anki-code/xontrib-sh";
              license = lib.licenses.mit;
              maintainers = [ ];
            };
          }
        ) { })
        (ps.callPackage (
          {
            buildPythonPackage,
            fetchFromGitHub,
            setuptools,
            writableTmpDirAsHomeHook,
            xonsh,
            nix-update-script,
            six,
            lib,
            ...
          }:
          buildPythonPackage rec {
            pname = "xontrib-pipeliner";
            version = "0.5.0";
            format = "setuptools";

            src = fetchFromGitHub {
              owner = "anki-code";
              repo = "xontrib-pipeliner";
              tag = version;
              hash = "sha256-rL0tssLtGE5dEovFpFnN95Jd0yaCyzciU0RUTakCUZ8=";
            };

            build-system = [
              setuptools
            ];

            nativeCheckInputs = [
              writableTmpDirAsHomeHook
              xonsh
            ];

            propagatedBuildInputs = [
              six
            ];

            passthru.updateScript = nix-update-script { };

            meta = {
              description = "Let your pipe lines flow thru the Python code in xonsh";
              homepage = "https://github.com/anki-code/xontrib-pipeliner";
              license = lib.licenses.bsd2;
              maintainers = [ ];
            };
          }
        ) { })
      ]
    );
  };
}
