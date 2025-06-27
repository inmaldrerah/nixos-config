{ pkgs, lib, ... }:
{
  shell = pkgs.xonsh;
  home-manager = { config, pkgs, nixvim, hm-extension, ... }: {
    imports = [
      nixvim.homeManagerModules.nixvim
      hm-extension.homeManagerModules.default
      ./nixvim.nix
      ./xonsh.nix
    ];

    home.stateVersion = "22.11";
    programs.home-manager.enable = true;

    programs.bash = {
      enable = false;
      shellOptions = [ "globstar" ];
      shellAliases = {
      };
      bashrcExtra = ''
        export TERM=xterm-256color
        export PATH=~/.local/bin:$PATH
        ulimit -Sn 524288
      '';
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.kitty = {
      enable = true;
      font.name = "Fira Code";
      font.size = 14;
      settings = {
        background_opacity = "0.8";
      };
    };

    programs.nix-index.enable = true;

    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-gstreamer
        obs-pipewire-audio-capture
        obs-vaapi
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

    programs.zed-editor = {
      enable = true;
      extensions = [ "nix" "toml" "c#" "make" ];
    };

    programs.zoxide.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      plugins = with pkgs.hyprlandPlugins; [
        hyprscrolling
      ];
      extraConfig = builtins.readFile ./hypr/hyprland.conf;
    };

    gtk = {
      enable = true;
      theme.name = "Adwaita-dark";
      theme.package = pkgs.gnome-themes-extra;
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
        
        "application/msword" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.openxmlformats-officedocument.wordprocessingml.template" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.ms-word.document.macroEnabled.12" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.ms-word.template.macroEnabled.12" = "onlyoffice-desktopeditors.desktop";

        "application/vnd.ms-excel" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.openxmlformats-officedocument.spreadsheetml.template" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.ms-excel.sheet.macroEnabled.12" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.ms-excel.template.macroEnabled.12" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.ms-excel.addin.macroEnabled.12" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.ms-excel.sheet.binary.macroEnabled.12" = "onlyoffice-desktopeditors.desktop";

        "application/vnd.ms-powerpoint" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.openxmlformats-officedocument.presentationml.template" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.openxmlformats-officedocument.presentationml.slideshow" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.ms-powerpoint.addin.macroEnabled.12" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.ms-powerpoint.presentation.macroEnabled.12" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.ms-powerpoint.template.macroEnabled.12" = "onlyoffice-desktopeditors.desktop";
        "application/vnd.ms-powerpoint.slideshow.macroEnabled.12" = "onlyoffice-desktopeditors.desktop";
      };
    };

    home.file.".bashrc".text = ''
        [[ $- == *i* ]] || return
        shopt -s globstar
        export TERM=xterm-256color
        export PATH=~/.local/bin:$PATH
        ulimit -Sn 524288
    '';

    # home.file.".config/hypr/hyprland.conf".source = ./hypr/hyprland.conf;
    home.file.".config/hypr/wlogout-layout".source = ./hypr/wlogout-layout;

    home.file.".config/waybar/config".source = ./waybar/config;
    home.file.".config/waybar/style.css".source = ./waybar/style.css;

    home.file.".config/wofi/style.css".source = ./wofi/style.css;

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
      # linyinfeng.wemeet
      lxqt.lxqt-policykit
      lxde.lxsession
      wineWowPackages.waylandFull
      swaynotificationcenter
      networkmanagerapplet
      lua-language-server
      nix-output-monitor
      deltachat-desktop 
      firefox-wayland
      mission-center
      onlyoffice-bin
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
      unityhub
      vscodium
      gtklock
      ripgrep
      wlogout
      waybar
      nodejs
      swappy
      trashy
      comma
      p7zip
      samba
      typst
      mono
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
      ".minikube"
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
      "Unity"
      "VirtualMachine"
      ".config/dconf"
      ".config/DeltaChat"
      ".config/environment.d"
      ".config/fcitx5"
      ".config/fontconfig"
      ".config/Google"
      ".config/gtk-3.0"
      ".config/libreoffice"
      ".config/libvirt"
      ".config/nixpkgs"
      ".config/obs-studio"
      ".config/pulse"
      ".config/swappy"
      ".config/unity3d"
      ".config/unityhub"
      ".config/VSCodium"
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
      "Videos"
    ];
  };
}
