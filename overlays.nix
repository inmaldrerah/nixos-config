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
    (self: super: {
      vscodium = super.vscodium.override { commandLineArgs = "--enable-wayland-ime"; };
    })
    nur-linyinfeng.overlays.default
  ];
in {
  nixpkgs.overlays = packageOverlays;
}
