{ config, lib, ... }:
let
  cfg = config.my.system.openssh;
in
{
  options.my.system.openssh = with lib; {
    enable = mkEnableOption "Enable openssh service";
  };

  config = lib.mkIf cfg.enable {

    services = {
      openssh = {
        enable = true;

        settings = {
          X11Forwarding = true;
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };

        extraConfig = ''
          MaxSessions 65
        '';
      };
    };
  };
}
