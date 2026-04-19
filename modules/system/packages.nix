{ config, lib, pkgs, ... }:
let
  cfg = config.my.system.packages;
in
{
  options.my.system.packages = with lib; {
    enable = mkOption { type = types.bool; default = true; };
    allowUnfree = mkOption { type = types.bool; default = true; };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wget
      vim
      git
    ];

    programs = {
      fish.enable = true;
    };

    nixpkgs.config = {
      allowUnfree = cfg.allowUnfree;
    };
  };
}
