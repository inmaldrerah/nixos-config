{
  home-manager = { pkgs, ... }: {
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
        export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib.outPath}/lib"
        ulimit -Sn 524288
        typst () {
          sh -c "typst $* \
            $(fc-list \
            | sed 's/^\(\/.*\/\).*$/--font-path \1/' \
            | sort \
            | sed '$!N; /^\(.*\)\n\1$/!P; D;' \
            | sed -e ':a; $!{N;ba;}' -e 's/\n/ /g')"
        }
        rebuild-system-local () {
          nom build "/etc/nixos#nixosConfigurations.\"$(uname -n)\".config.system.build.toplevel" &&
          nixos-rebuild --use-remote-sudo --flake /etc/nixos $*
        }
        rebuild-system () {
          nom build -j0 "/etc/nixos#nixosConfigurations.\"$(uname -n)\".config.system.build.toplevel" --option substituters \
            "https://nix-community.cachix.org https://cache.nixos.org/ http://nix-serve.router.local/" &&
          nixos-rebuild -j0 --use-remote-sudo --flake /etc/nixos $*
        }
      '';
    };

    programs.kitty = {
      enable = true;
      font.name = "Fira Code";
      font.size = 14;
      shellIntegration.enableBashIntegration = true;
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
      enableBashIntegration = true;
      settings = {
        manager.sort_by = "natural";
        manager.sort_reverse = false;
        manager.sort_sensitive = true;
      };
    };

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

    home.packages = with pkgs; [
      wineWowPackages.waylandFull
      swaynotificationcenter
      lua-language-server
      nix-output-monitor
      firefox-wayland
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
      gtklock
      ripgrep
      wlogout
      waybar
      nodejs
      swappy
      p7zip
      slurp
      typst
      grim
      wofi
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
      "Downloads"
      "VirtualMachine"
      ".config/alacritty"
      ".config/dconf"
      ".config/environment.d"
      ".config/fcitx5"
      ".config/fontconfig"
      ".config/gtk-3.0"
      ".config/hypr"
      ".config/libreoffice"
      ".config/libvirt"
      ".config/nixpkgs"
      ".config/nvim"
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
