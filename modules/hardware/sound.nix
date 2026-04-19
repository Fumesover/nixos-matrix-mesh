{ config, lib, ... }:
let
  cfg = config.my.hardware.sound;
in
{
  options.my.hardware.sound = with lib; {
    enable = mkEnableOption "Enable sound support";
  };

  config = lib.mkIf cfg.enable {
    # Required for paprefs
    programs.dconf.enable = true;

    # Enable sound.
    # services.pulseaudio = {
    #   enable = true;
    #   support32Bit = true;
    #
    #   tcp = {
    #     enable = true;
    #     anonymousClients.allowedIpRanges = [ "192.168.0.1/24" ];
    #   };
    #
    #   zeroconf = {
    #     publish.enable = true;
    #     discovery.enable = true;
    #   };
    # };
  };
}
