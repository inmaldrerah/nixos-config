{
  pkgs,
  ...
}:
{
  shell = pkgs.xonsh;

  shared-persistence = {
    directories = [
      "Pictures"
      "Videos"
    ];
  };
}
