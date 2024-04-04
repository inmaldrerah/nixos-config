{ pkgs, lib, nixvim, hm-extension, ... }:
{
  shell = pkgs.xonsh;
  home-manager = { pkgs, ... }: {
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
            return ![nom build --builders "" f'/etc/nixos#nixosConfigurations."{$(uname -n).strip()}".config.system.build.toplevel'] && \
              ![nixos-rebuild --use-remote-sudo --flake /etc/nixos @(args)]
          
          def __rebuild_system_remote(args):
            return ![nom build -j0 f'/etc/nixos#nixosConfigurations."{str($(uname -n)).strip()}".config.system.build.toplevel' --option substituters \
              "https://nix-community.cachix.org https://cache.nixos.org/ http://nix-serve.router.local/"] && \
              ![nixos-rebuild -j0 --use-remote-sudo --flake /etc/nixos @(args)]
          
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
            if __rebuild_system(args):
              target = p"/boot/loader/loader.conf".read_text().split()[4]
              ![sudo sh -c 'echo "timeout 5\ndefault @saved\nconsole-mode keep" > /boot/loader/loader.conf'] && \
                ![sudo bootctl set-oneshot @(target)]
          
          def toggle_nix_local(args):
            if "HOME" in ''${...} and $HOME != "" and pf"{$HOME}/.nix-local".is_file():
              $[rm "{$HOME}/.nix-local"]
            else:
              $[touch "{$HOME}/.nix-local"]
          
          aliases["rebuild-system"] = rebuild_system
          aliases["toggle-nix-local"] = toggle_nix_local
        
        __nix_helper_init()
        del __nix_helper_init
      '';
      extraConfig = ''
        $PATH.insert(0, f"{$HOME}/.local/bin")
        $TERM = "xterm-256color"
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

    home.file.".local/bin/typst" = {
      executable = true;
      text = ''
        #!/bin/sh
        /bin/sh -c "${pkgs.typst}/bin/typst $@ \
          $(${pkgs.fontconfig}/bin/fc-list \
          | sed 's/^\(\/.*\/\).*$/--font-path \1/' \
          | sort \
          | sed '$!N; /^\(.*\)\n\1$/!P; D;' \
          | sed -e ':a; $!{N;ba;}' -e 's/\n/ /g')"
      '';
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
      wl-clipboard
      libreoffice
      winetricks
      alacritty
      git-graph
      libnotify
      htop-vim
      swayidle
      swaylock
      vscodium
      hyprshot
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
