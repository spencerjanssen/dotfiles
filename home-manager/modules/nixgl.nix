{ dotfiles, ... }:
{
  targets.genericLinux = {
    nixGL = {
      packages = dotfiles.inputs.nixGL.packages;
      installScripts = [ "mesa" ];
    };
  };
}
