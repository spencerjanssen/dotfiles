{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Spencer Janssen";
        email = "spencerjanssen@gmail.com";
      };
      color = {
        ui = "auto";
      };
      push = {
        default = "simple";
      };
      merge = {
        conflictStyle = "diff3";
      };
    };
  };
}
