{ disko, config, pkgs, ... }:
{
  imports = [
    disko.nixosModules.disko

    ./configuration.nix
    ./hardware-configuration.nix
    ./users.nix
    ./networking.nix

    ./traefik.nix
    ./matrix.nix
  ];

  time.timeZone = "Europe/Paris";

  # system.stateVersion = "22.11";

  my.system.openssh.enable = true;
  my.networking.tailscale.enable = true;

  # Allow all users
  security.sudo.extraRules = [{
    users = [ "fumesover" ];
    runAs = "ALL:ALL";
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" ];
    }];
  }];
}
