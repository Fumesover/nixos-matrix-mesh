{ pkgs, config, lib, ... }:
let
  cfg = config.my.networking.tailscale;
in
{
  options.my.networking.tailscale = with lib; {
    enable = mkEnableOption "Enable tailscale";
  };

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;
    environment.systemPackages = [ pkgs.tailscale ];

    networking.firewall = {
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
      checkReversePath = "loose";
    };
  };
}
