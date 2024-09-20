{ nixpkgs-stable, ... }:
let
  pkgs = nixpkgs-stable.legacyPackages."x86_64-linux";
in {

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
    opts = {
      number = true;
      relativenumber = true;
      tabstop = 2;
      shiftwidth = 2;
      softtabstop = 2;
      expandtab = true;
      cursorline = true;
    };

    # Plugins
    extraPlugins = with pkgs.vimPlugins; [
      vim-suda
    ];
    plugins.transparent.enable = true;
    plugins.treesitter = {
      enable = true;
      nixGrammars = true;
      ensureInstalled = [ "nix" "c" "zig" "python" "typst" ];
    };
    plugins.persistence.enable = true;
    plugins.neo-tree = {
      enable = true;
      filesystem.filteredItems.visible = true;
      sourceSelector.statusline = true;
    };
    plugins.telescope = {
      enable = true;
      settings.defaults.layout_strategy = "bottom_pane";
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
      enable = false;
      keymaps = {
        close.key = "<A-w>";
        goTo1.key = "<A-1>";
        goTo2.key = "<A-2>";
        goTo3.key = "<A-3>";
        goTo4.key = "<A-4>";
        goTo5.key = "<A-5>";
        goTo6.key = "<A-6>";
        goTo7.key = "<A-7>";
        goTo8.key = "<A-8>";
        goTo9.key = "<A-9>";
        last.key = "<A-0>";
        previous.key = "<A-,>";
        next.key = "<A-.>";
        movePrevious.key = "<A-<>";
        moveNext.key = "<A->>";
        pin.key = "<A-p>";
        pick.key = "<C-p>";
      };
    };
    plugins.orgmode.enable = true;

    # Keymaps
    keymaps = [
      {
        key = "<A-n>";
        action = "<cmd>Neotree toggle<CR>";
        mode = ["n" "v" "i"];
        options = {
          silent = true;
        };
      }
    ];
  };
}
