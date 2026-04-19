{ config, pkgs, lib, ... }:
let
  cfg = config.my.system.wayland;

  swayConfig = pkgs.writeText "greetd-sway-config" ''
    # `-l` activates layer-shell mode
    exec ${pkgs.greetd.gtkgreet}/bin/gtkgreet -l; swaymsg exit
  '';
in
{
  options.my.system.wayland = with lib; {
    enable = mkEnableOption "Enable wayland support";
  };

  config = lib.mkIf cfg.enable {

    # greeter (login page)
    programs.regreet = {
      enable = true;
      settings = {
        default_session = {
          command = "sway";
          type = "wayland";
        };
      };
    };
    programs.sway.enable = true;

    # services.greetd = {
    #   enable = true;
    #   settings = {
    #     default_session = {
    #       command = "${pkgs.sway}/bin/sway"; # --config ${swayConfig}
    #       user = "fumesover";
    #     };
    #   };
    # };


    # xdg portal + pipewire = screensharing
    xdg.portal = {
      enable = true;
      wlr.enable = true;
    };
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    # security.pam.services.i3lock.enable = true;

    # services.xserver = {
    #   enable = true;
    #
    #   xkb.options = "caps:escape";
    #
    #   # libinput = true; # Supposed to be only for laptops
    #
    #   # Ensure the $DISPLAY variable is correctly set for pipentry-like tools
    #   updateDbusEnvironment = true;
    #
    #   windowManager.i3 = {
    #     enable = true;
    #     extraPackages = with pkgs ; [
    #       dmenu
    #       i3status
    #       i3lock
    #     ];
    #   };
    #
    #   displayManager.lightdm = {
    #     background = ./assets/alien-wallpaper.png;
    #   };
    # };
  };
}

