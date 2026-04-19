{ pkgs, utils, config, lib, ... }:
let
  cfg = config.my.system.zfs;
in
{
  options.my.system.zfs = with lib; {
    enable = mkEnableOption "Enable zfs support";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      boot = {
        supportedFilesystems = [ "zfs" ];
        # zfs.enableUnstable = true;
        # zfs.package = pkgs.zfs_unstable;

        kernelParams = [ "elevator=none" ];
      };

      services.zfs = {
        autoScrub.enable = true;
        trim.enable = true;
        autoSnapshot = {
          enable = true;

          flags = "-k -p --utc -v";

          frequent = 48;
          hourly = 48;
          daily = 14;
          weekly = 8;
          monthly = 12;
        };
      };


      # # Does not work since it would require pools on stage 1 and on stage 2
      # #
      # # Only load datasets required to mount the filesystem
      # # Warning: dataset with custom password on the root pool might break things

      # boot.zfs.requestEncryptionCredentials =
      #   with builtins; with utils; with lib;
      #   let
      #     # + From nixos/modules/tasks/filesystems/zfs.nix
      #     datasetToPool = x: elemAt (splitString "/" x) 0;
      #     fsToPool = fs: datasetToPool fs.device;
      #     zfsFilesystems = filter (x: x.fsType == "zfs") config.system.build.fileSystems;
      #     rootPools = unique (map fsToPool (filter fsNeededForBoot zfsFilesystems));
      #     # - From nixos/modules/tasks/filesystems/zfs.nix

      #     dataDatasets = unique (filter (dataset: !(elem (fsToPool dataset) rootPools)) zfsFilesystems);

      #     getDeviceName = fs: fs.device;
      #   in
      #     map getDeviceName dataDatasets;
    })
  ];
}
