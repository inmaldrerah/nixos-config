{
  config,
  nixpkgsInput,
  nixpkgs-extension,
  nix-vscode-extensions,
  nur-linyinfeng,
  ...
}:

let
  packageOverlays = [
    # nixpkgs-extension.overlays.default
    nix-vscode-extensions.overlays.default
    nur-linyinfeng.overlays.default
    (self: super: {
      xonsh.xontribs.xontrib-sh =
        with super;
        with super.python3Packages;
        (buildPythonPackage rec {
          pname = "xontrib-sh";
          version = "0.3.1";
          pyproject = false;

          src = fetchFromGitHub {
            owner = "anki-code";
            repo = "xontrib-sh";
            tag = version;
            hash = "sha256-R1DCGMrRCJLnz/QMk6QB8ai4nx88vvyPdaCKg3od5/I=";
          };

          build-system = [
            setuptools
          ];

          nativeCheckInputs = [
            writableTmpDirAsHomeHook
            pytestCheckHook
            xonsh
          ];

          passthru.updateScript = nix-update-script { };

          meta = {
            description = "Paste and run commands from bash, zsh, fish, tcsh, pwsh in xonsh shell";
            homepage = "https://github.com/anki-code/xontrib-sh";
            license = lib.licenses.mit;
            maintainers = with lib.maintainers; [ ];
          };
        });
    })
  ];
in
{
  nixpkgs.overlays = packageOverlays;
}
