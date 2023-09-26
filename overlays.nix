{ config, lib, nixpkgsFun, neovim-nightly-overlay, ... }:

let
  packageOverlays = [
    (self: super: {
      waybar = super.waybar.overrideAttrs (oldAttrs: rec {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      });
    })
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
    neovim-nightly-overlay.overlay
  ];
  stdenv = (nixpkgsFun {
    localSystem = config.nixpkgs.hostPlatform;
  }).stdenv;
  gnuOverlays = [
    (self: super: rec {
      pkgsGnu = nixpkgsFun {
        overlays = [ (self': super': {
          pkgsGnu = super';
        }) ];
        localSystem.parsed = stdenv.hostPlatform.parsed // {
          abi = lib.systems.parse.abis.gnu;
        };
      };
    })
  ];
  muslOverlays = [
    (self: super: {
      inherit (super.pkgsGnu) greetd libopus mesa pipewire samba direnv xray grub libinput virglrenderer libjxl wayland libproxy libqmi wayland-protocols graphviz glib-networking ffmpeg_4 ffmpeg_5 libcanberra gtk3 gtk4 swaybg wl-clipboard slurp grim swaylock swayidle gst_all_1 xwayland qtbase_6 qttools_6 wlroots_0_15 wlroots_0_16 networkmanager gtk-layer-shell wlroots-hyprland_0_17 wireplumber swappy wlogout wofi libjack2 libdbusmenu-gtk3 cage ;
    })
  ];
in {
  nixpkgs.overlays = if stdenv.hostPlatform.isMusl then
    gnuOverlays ++ muslOverlays ++ packageOverlays
  else
    gnuOverlays ++ packageOverlays;
  nixpkgs.config.replaceStdenv = if stdenv.hostPlatform.isMusl then
    { pkgs }: pkgs.ccacheStdenv
  else
    { pkgs }: pkgs.stdenv;
}
