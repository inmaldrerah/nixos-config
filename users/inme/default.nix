{
  pkgs,
  ...
}:
{
  shell = pkgs.xonsh;
  home-manager =
    {
      pkgs,
      inputs,
      ...
    }:
    {
      imports = [
        inputs.hm-extension.homeManagerModules.default
        inputs.noctalia.homeModules.default
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
          export PATH=~/.local/bin:$PATH
          ulimit -Sn 524288
        '';
      };

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      programs.helix = {
        enable = true;
        settings = {
          theme = "dracula_transparent";
          editor.cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
        };
        languages.language = [
          {
            name = "nix";
            auto-format = true;
            formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
          }
        ];
        extraPackages = with pkgs; [
          clang-tools
          jdt-language-server
          lua-language-server
          nixd
          taplo
          ty
          vscode-json-languageserver
          yaml-language-server
          zls
        ];
        themes.dracula_transparent = {
          inherits = "dracula";
          "ui.background" = { };
        };
      };

      programs.kitty = {
        enable = true;
        font.name = "Maple Mono NF CN";
        font.size = 14;
        settings = {
          background_opacity = "0.8";
        };
      };

      programs.nix-index.enable = true;

      programs.noctalia-shell = {
        enable = true;
        # settings = {
        #   dock = {
        #     enabled = true;
        #     pinnedApps = [ "Fcitx" ];
        #   };
        #   wallpapers = {
        #     enabled = true;
        #     overviewEnabled = true;
        #   };
        # };
      };

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
          mgr.sort_by = "natural";
          mgr.sort_reverse = false;
          mgr.sort_sensitive = true;
        };
      };

      programs.zed-editor = {
        enable = true;
        extensions = [
          "nix"
          "toml"
          "c#"
          "make"
        ];
      };

      programs.zoxide.enable = true;

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
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
            "onlyoffice-desktopeditors.desktop";
          "application/vnd.openxmlformats-officedocument.wordprocessingml.template" =
            "onlyoffice-desktopeditors.desktop";
          "application/vnd.ms-word.document.macroEnabled.12" = "onlyoffice-desktopeditors.desktop";
          "application/vnd.ms-word.template.macroEnabled.12" = "onlyoffice-desktopeditors.desktop";

          "application/vnd.ms-excel" = "onlyoffice-desktopeditors.desktop";
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" =
            "onlyoffice-desktopeditors.desktop";
          "application/vnd.openxmlformats-officedocument.spreadsheetml.template" =
            "onlyoffice-desktopeditors.desktop";
          "application/vnd.ms-excel.sheet.macroEnabled.12" = "onlyoffice-desktopeditors.desktop";
          "application/vnd.ms-excel.template.macroEnabled.12" = "onlyoffice-desktopeditors.desktop";
          "application/vnd.ms-excel.addin.macroEnabled.12" = "onlyoffice-desktopeditors.desktop";
          "application/vnd.ms-excel.sheet.binary.macroEnabled.12" = "onlyoffice-desktopeditors.desktop";

          "application/vnd.ms-powerpoint" = "onlyoffice-desktopeditors.desktop";
          "application/vnd.openxmlformats-officedocument.presentationml.presentation" =
            "onlyoffice-desktopeditors.desktop";
          "application/vnd.openxmlformats-officedocument.presentationml.template" =
            "onlyoffice-desktopeditors.desktop";
          "application/vnd.openxmlformats-officedocument.presentationml.slideshow" =
            "onlyoffice-desktopeditors.desktop";
          "application/vnd.ms-powerpoint.addin.macroEnabled.12" = "onlyoffice-desktopeditors.desktop";
          "application/vnd.ms-powerpoint.presentation.macroEnabled.12" = "onlyoffice-desktopeditors.desktop";
          "application/vnd.ms-powerpoint.template.macroEnabled.12" = "onlyoffice-desktopeditors.desktop";
          "application/vnd.ms-powerpoint.slideshow.macroEnabled.12" = "onlyoffice-desktopeditors.desktop";
        };
      };

      home.file.".bashrc".text = ''
        [[ $- == *i* ]] || return
        shopt -s globstar
        export PATH=~/.local/bin:$PATH
        ulimit -Sn 524288
      '';

      home.file.".cache/noctalia/wallpapers.json" = {
        text = builtins.toJSON {
          defaultWallpaper = "/home/inme/Pictures/Wallpapers/wallpaper";
        };
      };

      home.file.".config/niri/config.kdl".source = ./niri/config.kdl;

      home.packages = with pkgs; [
        wineWowPackages.waylandFull
        onlyoffice-desktopeditors
        lua-language-server
        nix-output-monitor
        deltachat-desktop
        mission-center
        wl-clipboard
        libreoffice
        winetricks
        alacritty
        git-graph
        libnotify
        p7zip-rar
        htop-vim
        tinymist
        vscodium
        firefox
        gtklock
        ripgrep
        nodejs
        swappy
        swaybg
        waybar
        wemeet
        comma
        samba
        typst
        mono
        dex
        rmw
        git
        zig
        (vscode-with-extensions.override {
          vscodeExtensions =
            with (nix-vscode-extensions.forVSCodeVersion pkgs.vscode.version).vscode-marketplace; [
              asciidoctor.asciidoctor-vscode
              github.copilot
              github.copilot-chat
              llvm-vs-code-extensions.vscode-clangd
              mhutchie.git-graph
              mkhl.direnv
              vscjava.vscode-gradle
              vscjava.vscode-java-debug
              vscjava.vscode-java-dependency
              vscjava.vscode-java-pack
              vscjava.vscode-java-test
              vscjava.vscode-maven
            ];
        })
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
      ".vscode-oss"
      ".wine"
      "Builds"
      "Desktop"
      "Downloads"
      "Games"
      "Share"
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
      ".config/noctalia"
      ".config/obs-studio"
      ".config/pulse"
      ".config/swappy"
      ".config/VSCodium"
      ".config/zeditor"
    ];
    files = [
      ".bash_history"
      ".gitconfig"
      ".repo_.gitconfig.json"
      ".config/rmwrc"
    ];
  };

  shared-persistence = {
    directories = [
      "Pictures"
      "Videos"
    ];
  };
}
