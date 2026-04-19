{ config, pkgs, ... }:
let
  secrets = config.my.secrets;
in
{
  users = {
    mutableUsers = false;

    users = {
      root = {};

      fumesover = {
        isNormalUser = true;
        shell = pkgs.fish;

        extraGroups = [
          "wheel" "docker"
        ];

        openssh.authorizedKeys.keys = secrets.users.fumesover.authorizedKeys;
      };
    };
  };
}


