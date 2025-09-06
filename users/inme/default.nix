{ pkgs, lib, ... }:
{
  shell = pkgs.bash;
  home-manager = { config, pkgs, ... }: {
    imports = [
    ];

    home.stateVersion = "22.11";
    programs.home-manager.enable = true;

    programs.bash = {
      enable = false;
      shellOptions = [ "globstar" ];
      shellAliases = {
      };
      bashrcExtra = ''
        export TERM=xterm-256color
        export PATH=~/.local/bin:$PATH
        ulimit -Sn 524288
      '';
    };

    programs.yazi = {
      enable = true;
      settings = {
        manager.sort_by = "natural";
        manager.sort_reverse = false;
        manager.sort_sensitive = true;
      };
    };

    programs.zoxide.enable = true;

    home.file."test.nix".text = ''
      { pkgs ? import <nixpkgs> {} }:
      pkgs.fetchgit {
        url = "https://github.com/nixos/nixpkgs";
        rev = "aaff8c16d7fc04991cac6245bee1baa31f72b1e1";
      }
    '';

    home.file.".bashrc".text = ''
        [[ $- == *i* ]] || return
        shopt -s globstar
        export TERM=xterm-256color
        export PATH=~/.local/bin:$PATH
        ulimit -Sn 524288
    '';

    home.packages = with pkgs; [
      wl-clipboard
      ripgrep
      git
      zig
    ];
  };
}
