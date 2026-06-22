{ ... }:
{
  networking = {
    hostName = "exo-nixos-2"; # Define your hostname.
    hostId = "2ca243ce";

    firewall.allowedTCPPorts = [
      # traefik
      80
      443
    ];
  };
}
