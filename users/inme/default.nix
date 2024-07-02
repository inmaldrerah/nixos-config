{ pkgs, lib, nixvim, hm-extension, ... }:
{
  shell = pkgs.xonsh;
  home-manager = { config, pkgs, ... }: {
    imports = [
      nixvim.homeManagerModules.nixvim
      hm-extension.homeManagerModules.default
      ./nixvim.nix
    ];

    home.stateVersion = "22.11";
    programs.home-manager.enable = true;

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.bash = {
      enable = true;
      shellOptions = [ "globstar" ];
      shellAliases = {
      };
      bashrcExtra = ''
        export TERM=xterm-256color
        export PATH=~/.local/bin:$PATH
        ulimit -Sn 524288
      '';
    };

    programs.xonsh = {
      enable = true;
      rcFiles."nix-helper.xsh".text = ''
        def __nix_helper_init():
          def __rebuild_system_local(args):
            # return ![nom build --builders "" f'/etc/nixos#nixosConfigurations."{$(uname -n).strip()}".config.system.build.toplevel'] && \
            #   ![nixos-rebuild --use-remote-sudo --flake /etc/nixos @(args)]
            return ![nixos-rebuild -v --builders "" --use-remote-sudo --flake /etc/nixos @(args)]
          
          def __rebuild_system_remote(args):
            substituters = tuple(map(lambda s: s[len("trusted-substituters = "):], filter(lambda s: s.startswith("trusted-substituters = "), p"/etc/nix/nix.conf".read_text().split("\n"))))[0]
            # return ![nom build -j0 f'/etc/nixos#nixosConfigurations."{str($(uname -n)).strip()}".config.system.build.toplevel' --option substituters @(substituters)] && \
            #   ![nixos-rebuild -j0 --use-remote-sudo --flake /etc/nixos @(args)]
            return ![nixos-rebuild -j0 -v --option substituters @(substituters) --use-remote-sudo --flake /etc/nixos @(args)]
          
          def __commit_nixos_config(args):
            current_pwd = $PWD
            $[cd /etc/nixos]
            $[git add .]
            $[git commit -m f"snapshot@{str($(date -u +%m/%d/%Y-%T)).strip()}"]
            $[cd @(current_pwd)]
         
          def __rebuild_system(args):
            __commit_nixos_config(args)
            if pf"{$HOME}/.nix-local".is_file():
              return __rebuild_system_local(args)
            else:
              return __rebuild_system_remote(args)
          
          def rebuild_system(args):
            rebuild_status = __rebuild_system(args)
            if any(map(lambda x: x in args, ["switch", "boot"])):
              target = p"/boot/loader/loader.conf".read_text().split()[3]
              print(f"setting default to @saved and oneshot to {target}")
              ![sudo bootctl set-default "@saved"] && \
                ![sudo bootctl set-oneshot @(target)]
            return rebuild_status
          
          def toggle_nix_local(args):
            if "HOME" in ''${...} and $HOME != "" and pf"{$HOME}/.nix-local".is_file():
              $[rm f"{$HOME}/.nix-local"]
            else:
              $[touch f"{$HOME}/.nix-local"]
          
          aliases["rebuild-system"] = rebuild_system
          aliases["toggle-nix-local"] = toggle_nix_local
        
        __nix_helper_init()
        del __nix_helper_init
      '';
      extraConfig = ''
        if not ''${...}.get(f"__USER_{$USER}_SETUP_DONE"):
          $PATH.insert(0, f"{$HOME}/.local/bin")
          $TERM = "xterm-256color"
          ''${f"__USER_{$USER}_SETUP_DONE"} = "1"
      '';
    };

    programs.kitty = {
      enable = true;
      font.name = "Fira Code";
      font.size = 14;
      settings = {
        background_opacity = "0.8";
      };
    };

    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-gstreamer
        # obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };

    programs.yazi = {
      enable = true;
      enableXonshIntegration = true;
      settings = {
        manager.sort_by = "natural";
        manager.sort_reverse = false;
        manager.sort_sensitive = true;
      };
    };

    programs.zoxide.enable = true;

    gtk = {
      enable = true;
      theme.name = "Adwaita-dark";
      theme.package = pkgs.gnome.gnome-themes-extra;
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "application/pdf" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/mailto" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
      };
    };

    home.file.".local/bin/caffine" = {
      executable = true;
      text = ''
        #!/bin/sh
        case "$@" in 
          "toggle"|"")
            if [ -f "$HOME/.caffine" ]; then
              err="$(rm "$HOME/.caffine" 2>&1 > /dev/null)"
            else
              err="$(touch "$HOME/.caffine" 2>&1 > /dev/null)"
            fi
            if [ "$err" == "" ]; then
              if [[ -f "$HOME/.caffine" ]]; then
                notify-send "Caffine ON" "Caffine is toggled on." --icon=dialog-information
              else
                notify-send "Caffine OFF" "Caffine is toggled off." --icon=dialog-information
              fi
            else
              notify-send "Caffine Toggle Error" "Error: $err" --icon=dialog-error
            fi;;
          "waybar")
            prev="none"
            while :; do
              if [ -f "$HOME/.caffine" ]; then
                if [ $prev != "on" ]; then
                  echo '{"text": "on", "alt": "on", "tooltip": "", "class": "on"}'
                  prev="on"
                fi
              else
                if [ $prev != "off" ]; then
                  echo '{"text": "off", "alt": "off", "tooltip": "", "class": "off"}'
                  prev="off"
                fi
              fi
              sleep 1
            done;;
        esac
      '';
    };

    home.packages = with pkgs; [
      wineWowPackages.waylandFull
      swaynotificationcenter
      lua-language-server
      nix-output-monitor
      firefox-wayland
      onlyoffice-bin
      typst-preview
      wl-clipboard
      libreoffice
      winetricks
      alacritty
      git-graph
      libnotify
      htop-vim
      hyprshot
      swayidle
      swaylock
      tinymist
      vscodium
      gtklock
      ripgrep
      wlogout
      waybar
      nodejs
      swappy
      trashy
      p7zip
      samba
      typst
      wofi
      dex
      git
      zig
    ];
  };

  persistence = {
    directories = [
      ".android"
      ".cache"
      ".cargo"
      ".gnupg"
      ".gradle"
      ".local"
      ".mozilla"
      ".npm"
      ".repoconfig"
      ".rustup"
      ".ssh"
      ".texlive2022"
      ".vscode-oss"
      ".wine"
      "Builds"
      "Desktop"
      "Downloads"
      "Games"
      "Share"
      "VirtualMachine"
      ".config/alacritty"
      ".config/dconf"
      ".config/environment.d"
      ".config/fcitx5"
      ".config/fontconfig"
      ".config/Google"
      ".config/gtk-3.0"
      ".config/hypr"
      ".config/libreoffice"
      ".config/libvirt"
      ".config/nixpkgs"
      # ".config/nvim"
      ".config/pulse"
      ".config/qtile"
      ".config/swappy"
      ".config/sway"
      ".config/VSCodium"
      ".config/waybar"
      ".config/wofi"
    ];
    files = [
      ".bash_history"
      ".gitconfig"
      ".repo_.gitconfig.json"
    ];
  };

  shared-persistence = {
    directories = [
      "Pictures"
    ];
  };
}
