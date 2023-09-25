{

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = { self, nixpkgs }:
  let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
    };
  in
  {
    devShells."x86_64-linux".default = (pkgs.buildFHSEnv {
      name = "neovim-env";
      targetPkgs = pkgs: (with pkgs; [
        neovim
      ]);
      runScript = "nvim";
    }).env;
  };

}
