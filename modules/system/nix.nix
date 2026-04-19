{ pkgs, inputs, config, lib, ... }:
let
  cfg = config.my.system.nix;
in
{
  options.my.system.nix = with lib; with types; {
    enable = mkOption { type = bool; default = true; description = "Enable full nix support"; };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      nix = rec {
        package = pkgs.nix;
        extraOptions = ''
          experimental-features = nix-command flakes
        '';

        registry = {
          self.flake = inputs.self;
          nixpkgs.flake = inputs.nixpkgs;

          # nixpkgs-unfree.flake = inputs.nixpkgs-unfree;

          # nixpkgs-unfree.flake =
          #   let
          #     lib = inputs.nixpkgs.lib;
          #   in
          #   inputs.nixpkgs // {
          #     legacyPackages = lib.genAttrs lib.systems.supported.hydra (system:
          #       import inputs.nixpkgs { inherit system; config.allowUnfree = true; }
          #     );
          #   };
        };

        settings = {
          auto-optimise-store = true;

          # TODO: Use a group for that
          trusted-users = [
            "fumesover"
          ];
        };
      };
    })
  ];
}
