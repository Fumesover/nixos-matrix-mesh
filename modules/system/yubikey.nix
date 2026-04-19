{ config, lib, pkgs, ... }:
let
  cfg = config.my.system.yubikey;
in
{
  options.my.system.yubikey = with lib; {
    enable = mkEnableOption "Activate support for yubikey";
  };

  config = lib.mkIf cfg.enable {

    services.pcscd = {
      enable = true;
      plugins = [
        pkgs.yubikey-personalization
      ];
    };

    services.udev.packages = with pkgs; [
      libu2f-host
      yubikey-personalization
    ];

    environment.systemPackages = with pkgs; [
      yubikey-personalization
    ];

    services.dbus.packages = [ pkgs.gcr ];
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # Testing things...
    hardware.gpgSmartcards.enable = true;
  };
}
