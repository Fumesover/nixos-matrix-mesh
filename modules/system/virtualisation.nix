{ lib, config, pkgs, ... }:
let
  cfg = config.my.system.virtualisation;
in
{
  options.my.system.virtualisation = with lib; {
    docker = {
      enable = mkEnableOption "Enable docker service";
      onlySocket = mkEnableOption "Enable docker service on docker only";
    };

    libvirtd = {
      enable = mkEnableOption "Enable libvirt service";
    };

    virtualbox = {
      enable = mkEnableOption "Enable virtualbox service";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.docker.enable {
      virtualisation.docker = {
        enable = true;
        storageDriver = lib.mkIf config.my.system.zfs.enable "zfs";
        enableOnBoot = !cfg.docker.onlySocket;
      };
    })

    (lib.mkIf cfg.libvirtd.enable {
      virtualisation.libvirtd = {
        enable = cfg.libvirtd.enable;
        qemu.swtpm.enable = true;
      };

      virtualisation.spiceUSBRedirection.enable = true;

      environment.systemPackages = with pkgs; [
        virt-manager
      ];
    })

    ({
      virtualisation.virtualbox.host.enable = cfg.virtualbox.enable;
    })
  ];
}

