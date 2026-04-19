{ config, lib, ... }:

let
  cfg = config.my.hardware.networking;
in
{
  # options.my.hardware.networking = {
  #   networkmanager = {
  #     enable = lib.mkEnableOption "networkmanager config";
  #   };
  # };

  # config = lib.mkMerge [
  #   (lib.mkIf cfg.networkmanager.enable {
  #     networking.networkmanager.enable = true;
  #   })
  # ];

  config = lib.mkMerge [
    # { services.avahi.enable = true; }
  ];
}
