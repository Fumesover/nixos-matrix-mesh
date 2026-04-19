{ config, lib, ... }:
let
  cfg = config.my.system.boot;
in
{
  options.my.system.boot = with lib; {

    loader.enable = mkEnableOption "Enable default system loader";

    initrd = {
      enable = mkEnableOption "Enable initrd server for remote unlock";
      authorizedKeys = with types; mkOption {
        type = listOf str;
        default = [ ];
      };
    };

  };

  config = lib.mkMerge [
    (lib.mkIf cfg.loader.enable {
      boot.loader = {
        systemd-boot.enable = true;
        systemd-boot.memtest86.enable = true;
        efi.canTouchEfiVariables = true;
      };
    })

    (lib.mkIf cfg.initrd.enable {
      boot.initrd.network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2222;

          # Key generation:
          # > mkdir -p /persist/etc/secrets/initrd/
          # > ssh-keygen -t rsa -N "" -f /persist/etc/secrets/initrd/ssh_host_rsa_key
          # > ssh-keygen -t ed25519 -N "" -f  /persist/etc/secrets/initrd/ssh_host_ed25519_key
          hostKeys = [
            /persist/etc/secrets/initrd/ssh_host_rsa_key
            /persist/etc/secrets/initrd/ssh_host_ed25519_key
          ];

          authorizedKeys = cfg.initrd.authorizedKeys;
        };

        postCommands = ''
          echo "zfs load-key -a; killall zfs" >> /root/.profile
        '';
      };

    })
  ];
}
