{ config, pkgs, ... }:
{
  services.xserver.xkb.dir = let
    layouts = {
      us-qwpr = {
        description = "US QWPR layout";
        languages = [ "eng" ];
        symbolsFile = xkb/symbols/us-qwpr;
      };
    };
    options = {
      super = {
        description = "Super behavior";
        optionDescriptions.arrow_keys = "Super + Up/Down/Left/Right is mapped to PageUp/PageDown/Home/End";
        symbolsFile = xkb/symbols/super;
      };
    };
    xkbPatched = pkgs.xorg.xkeyboardconfig_custom { inherit layouts; };
  in "${xkbPatched}/etc/X11/xkb";
  environment.sessionVariables.XKB_CONFIG_ROOT = config.services.xserver.xkb.dir;
  services.xserver.exportConfiguration = config.services.xserver.displayManager.startx.enable
      || config.services.xserver.displayManager.sx.enable;
}
