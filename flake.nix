{
  description = "NixOS configurationn with flakes";
  inputs = {
    futils.url          = "github:numtide/flake-utils?ref=main";
    nixpkgs.url         = "github:NixOS/nixpkgs?ref=master";
    disko.url           = "github:nix-community/disko";

    disko.inputs.nixpkgs.follows = "nixpkgs";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix?ref=master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs =
    inputs @
    { self
    , futils
    , nixpkgs
    , pre-commit-hooks
    , disko
    }:
    let
      inherit (futils.lib) eachDefaultSystem;

      lib = nixpkgs.lib.extend (self: super: {
        my = import ./lib { inherit inputs; pkgs = nixpkgs; lib = self; };
      });

      defaultModules = [
        ({ ... }: {
          # Let 'nixos-version --json' know about the Git revision
          system.configurationRevision = self.rev or "dirty";
        })

        ./modules
        # ./services
        ./secrets

        # For matrix-appservice-irc, we need to replace the nodejs version
        ({ pkgs, ... }: {
          nixpkgs.overlays = [
            (final: prev: {
              # Override nodejs-slim to v22 for matrix-appservice-irc
              nodejs-slim = prev.nodejs-slim_22;
            })
          ];
        })
      ];

      buildHost = name: system: lib.nixosSystem {
        inherit system;
        modules = defaultModules ++ [
          (./. + "/machines/${name}")
        ];
        specialArgs = {
          inherit lib;
          inherit inputs;
          inherit disko;
        };
      };
    in
    eachDefaultSystem
      (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        # apps = {
        #     diff-flake = futils.lib.mkApp { drv = packages.diff-flake; };
        # };

        checks = {
          pre-commit = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixpkgs-fmt.enable = true;
            };
          };
        };

        # defaultApp = apps.diff-flake;

        devShell = pkgs.mkShell {
          name = "NixOS-config";

          buildInputs = with pkgs; [
            git-crypt
            gitAndTools.pre-commit
            gnupg
            nixpkgs-fmt
          ];

          inherit (self.checks.${system}.pre-commit) shellHook;
        };

        packages =
          let
            inherit (futils.lib) filterPackages flattenTree;
            packages = import ./pkgs { inherit pkgs; };
            flattenedPackages = flattenTree packages;
            finalPackages = filterPackages system flattenedPackages;
          in
          finalPackages;
      }) // {
      overlay = self.overlays.pkgs;
      overlays = import ./overlays // {
        lib = final: prev: { inherit lib; };
        pkgs = final: prev: { fumesover = import ./pkgs { pkgs = prev; }; };
      };

      nixosConfigurations = lib.mapAttrs buildHost {
        # exo-nixos-2 = "x86_64-linux";

        nixos-tuwumesh-1 = "x86_64-linux";
        nixos-tuwumesh-2 = "x86_64-linux";
        nixos-tuwumesh-3 = "x86_64-linux";
        nixos-tuwumesh-4 = "x86_64-linux";
      };
    };
}
