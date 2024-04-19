{ config, pkgs, lib, ... }:

with lib;

let
  layouts = config.services.xserver.xkb.extraConfig.layouts;
  options = config.services.xserver.xkb.extraConfig.options;

  sharedOpts = {
    options = {
      description = mkOption {
        type = types.str;
        description = lib.mdDoc "A short description of the layout.";
      };

      compatFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = lib.mdDoc ''
          The path to the xkb compat file.
          This file sets the compatibility state, used to preserve
          compatibility with xkb-unaware programs.
          It must contain a `xkb_compat "name" { ... }` block.
        '';
      };

      geometryFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = lib.mdDoc ''
          The path to the xkb geometry file.
          This (completely optional) file describes the physical layout of
          keyboard, which maybe be used by programs to depict it.
          It must contain a `xkb_geometry "name" { ... }` block.
        '';
      };

      keycodesFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = lib.mdDoc ''
          The path to the xkb keycodes file.
          This file specifies the range and the interpretation of the raw
          keycodes sent by the keyboard.
          It must contain a `xkb_keycodes "name" { ... }` block.
        '';
      };

      symbolsFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = lib.mdDoc ''
          The path to the xkb symbols file.
          This is the most important file: it defines which symbol or action
          maps to each key and must contain a
          `xkb_symbols "name" { ... }` block.
        '';
      };

      typesFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = lib.mdDoc ''
          The path to the xkb types file.
          This file specifies the key types that can be associated with
          the various keyboard keys.
          It must contain a `xkb_types "name" { ... }` block.
        '';
      };

    };
  };

  layoutOpts = recursiveUpdate sharedOpts {
    languages = {
      type = types.listOf types.str;
      description =
        lib.mdDoc ''
          A list of languages provided by the layout.
        '';
    };
  };

  optionOpts = recursiveUpdate sharedOpts {
    options = {
      optionDescriptions = mkOption {
        type = types.attrsOf types.str;
        description =
          lib.mdDoc ''
            An attrset of options provided by the option file.
          '';
      };
    };
  };

  xkb_patched = pkgs.xorg.xkeyboardconfig_custom {
    inherit layouts;
    inherit options;
  };

in

{

  options.services.xserver.xkb.extraConfig = {
    layouts = mkOption {
      type = types.attrsOf (types.submodule layoutOpts);
      default = { };
      description = lib.mdDoc ''
        Extra custom layouts that will be included in the xkb configuration.
      '';
    };
    options = mkOption {
      type = types.attrsOf (types.submodule optionOpts);
      default = { };
      description = lib.mdDoc ''
        Extra custom options that will be included in the xkb configuration.
      '';
    };
  };

  config = (mkIf (false && (layouts != { } || options != { })) {

    environment.sessionVariables = {
      # runtime override supported by multiple libraries e. g. libxkbcommon
      # https://xkbcommon.org/doc/current/group__include-path.html
      XKB_CONFIG_ROOT = config.services.xserver.xkb.dir;
    };

    services.xserver = {
      xkb.dir = mkForce "${xkb_patched}/etc/X11/xkb";
      exportConfiguration = config.services.xserver.displayManager.startx.enable
        || config.services.xserver.displayManager.sx.enable;
    };

  });
}
