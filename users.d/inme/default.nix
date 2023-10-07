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
        rebuild-system () {
          nom build "/etc/nixos#nixosConfigurations.\"$(uname -n)\".config.system.build.toplevel" &&
          nixos-rebuild --use-remote-sudo --flake /etc/nixos $*
        }
      '';
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/mailto" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
      };
    };

    home.packages = with pkgs; [
      lua-language-server
      nix-output-monitor
      firefox-wayland
      wl-clipboard
      alacritty
      git-graph
      htop-vim
      swayidle
      swaylock
      neovide
      ripgrep
      wlogout
      waybar
      nodejs
      swappy
      slurp
      typst
      unzip
      grim
      wofi
      git
    ];
  };

  persistence = {
    directories = [
      ".android"
      ".cache"
      ".cargo"
      ".ccache"
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
      "Builds"
      "Downloads"
      "Pictures"
      "VirtualMachine"
      ".config/alacritty"
      ".config/coc"
      ".config/dconf"
      ".config/environment.d"
      ".config/fcitx5"
      ".config/fontconfig"
      ".config/gtk-3.0"
      ".config/hypr"
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
}
