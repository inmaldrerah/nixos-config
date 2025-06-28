{ config, lib, nixpkgsInput, neovim-nightly-overlay, nur-linyinfeng, ... }:

let
  packageOverlays = [
    (self: super: {
      ccacheWrapper = super.ccacheWrapper.override {
        extraConfig = ''
          export CCACHE_COMPRESS=1
          export CCACHE_DIR="${config.programs.ccache.cacheDir}"
          export CCACHE_UMASK=007
          if [ ! -d "$CCACHE_DIR" ]; then
            echo "====="
            echo "Directory '$CCACHE_DIR' does not exist"
            echo "Please create it with:"
            echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
            echo "  sudo chown root:nixbld '$CCACHE_DIR'"
            echo "====="
            exit 1
          fi
          if [ ! -w "$CCACHE_DIR" ]; then
            echo "====="
            echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
            echo "Please verify its access permissions"
            echo "====="
            exit 1
          fi
        '';
      };
    })
    # neovim-nightly-overlay.overlay
    nur-linyinfeng.overlays.default
    (self: super: {
      hyprlandPlugins.hyprscrolling = super.hyprlandPlugins.hyprscrolling.overrideAttrs (old:
      let
        hyprland-plugins-src = super.fetchFromGitHub {
          owner = "hyprwm";
          repo = "hyprland-plugins";
          rev = "dd28351a6181c37553cca1ce437f0049dcd3ee5f";
          hash = "sha256-z6SyE2jxpLqW7zJGl5bgH5zTWPv6vhVZaSHx/JW6Faw=";
        };
      in {
        src = "${hyprland-plugins-src}/hyprscrolling";
      });
    })
  ];
in {
  nixpkgs.overlays = packageOverlays;
}
