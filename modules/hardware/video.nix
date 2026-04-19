{ config, lib, ... }:
{
  options.my.hardware.video = with lib; with types; {
    enable = mkOption { type = bool; default = true; description = "Enable video fixes"; };
  };

  config = {
    # Fixing opengl for steam
    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;
  };
}
