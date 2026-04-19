{ config, pkgs, lib, ... }:
let
  cfg = config.my.system.x11;
in
{
  options.my.system.x11 = with lib; {
    enable = mkEnableOption "Enable x11 support";
  };

  config = lib.mkIf cfg.enable {

    security.pam.services.i3lock.enable = true;

    services.xserver = {
      enable = true;

      xkb.options = "caps:escape";

      # libinput = true; # Supposed to be only for laptops

      # Ensure the $DISPLAY variable is correctly set for pipentry-like tools
      updateDbusEnvironment = true;

      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs ; [
          dmenu
          i3status
          i3lock
        ];
      };

      displayManager.lightdm = {
        background = ./assets/alien-wallpaper.png;
      };
    };
  };
}
