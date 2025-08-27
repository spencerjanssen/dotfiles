{ dotfiles, ... }:
{
  nixGL = {
    packages = dotfiles.inputs.nixGL.packages;
    installScripts = [ "mesa" ];
  };
}
