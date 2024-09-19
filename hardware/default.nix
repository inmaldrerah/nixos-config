{ hostName, ... }@args:
{
  imports = [
    ./${hostName}.nix
  ];
}
