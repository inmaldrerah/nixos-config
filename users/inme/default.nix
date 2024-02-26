{ lib, nixvim, ... }:
{
  home-manager = { pkgs, ... }: {
    imports = [
      nixvim.homeManagerModules.nixvim
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

    programs.nixvim = {
      enable = true;

      # Color Scheme
      colorschemes.base16 = {
        enable = true;
        colorscheme = "material";
      };

      # Clipboard
      clipboard.register = "unnamedplus";
      clipboard.providers.wl-copy.enable = true;
      globals.clipboard = {
        name = "wl-copy";
        copy."+" = [ "wl-copy" ];
        copy."*" = [ "wl-copy" ];
        paste."+" = [ "wl-paste" "-n" ];
        paste."*" = [ "wl-paste" "-n" ];
        cache_enabled = true;
      };

      # Options
      options = {
        number = true;
        relativenumber = true;
        tabstop = 2;
        shiftwidth = 2;
        softtabstop = 2;
        expandtab = true;
        cursorline = true;
      };

      # Plugins
      plugins.neo-tree = {
        enable = true;
        filesystem.filteredItems.visible = true;
        sourceSelector.statusline = true;
      };
      plugins.persistence.enable = true;
      plugins.telescope = {
        enable = true;
        defaults.layout_strategy = "bottom_pane";
      };
      plugins.alpha = {
        enable = true;
        theme.__raw = ''
          (function()
            local dashboard = require("alpha.themes.dashboard")
            dashboard.section.buttons.val = {
              dashboard.button("e", "  New file", "<cmd>ene <CR>"),
              dashboard.button("ff", "󰈞  Find file", "<cmd>Telescope find_files<CR>"),
              dashboard.button("fh", "󰊄  Recently opened files", "<cmd>Telescope oldfiles<CR>"),
              dashboard.button("fr", "  Frecency/MRU"),
              dashboard.button("fg", "󰈬  Find word"),
              dashboard.button("fm", "  Jump to bookmarks"),
              dashboard.button("sl", "  Open last session", [[<cmd>lua require("persistence").load({ last = true })<cr>]]),
            }
            return dashboard.config
          end)()
        '';
      };
      plugins.barbar = {
        enable = true;
        keymaps = {
          close = "<A-w>";
          goTo1 = "<A-1>";
          goTo2 = "<A-2>";
          goTo3 = "<A-3>";
          goTo4 = "<A-4>";
          goTo5 = "<A-5>";
          goTo6 = "<A-6>";
          goTo7 = "<A-7>";
          goTo8 = "<A-8>";
          goTo9 = "<A-9>";
          last = "<A-0>";
          previous = "<A-,>";
          next = "<A-.>";
          movePrevious = "<A-<>";
          moveNext = "<A->>";
          pin = "<A-p>";
          pick = "<C-p>";
          silent = true;
        };
      };

      # Keymaps
      keymaps = [
        {
          key = "<A-m>";
          action = "<cmd>Neotree toggle<CR>";
          mode = ["n" "v" "i"];
          options = {
            silent = true;
          };
        }
      ];
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
      hyprshot
      gtklock
      ripgrep
      wlogout
      waybar
      nodejs
      swappy
      p7zip
      typst
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
