{ pkgs, ... }: {

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
      # suda-vim
    ];
    plugins.transparent.enable = true;
    plugins.treesitter = {
      enable = true;
      nixGrammars = true;
      ensure_installed = [ "nix" "c" "zig" "python" "typst" ];
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
}
