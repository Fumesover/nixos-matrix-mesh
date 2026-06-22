{ pkgs, lib, config, ... }:

{
  services.nginx = {
    enable = true;

    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    virtualHosts."${config.networking.hostName}.parou.eu" = {
      addSSL = false;
      forceSSL = false;

      listen = [
        { addr = "127.0.0.1"; port = 8042; }
      ];

      locations."= /index.md" = {
        alias = ./exo-how-to.md;
        extraConfig = ''
          default_type text/markdown;
        '';
      };
    };

    virtualHosts."cinny.${config.networking.hostName}.parou.eu" = {
      addSSL = false;
      forceSSL = false;

      listen = [
        { addr = "127.0.0.1"; port = 8042; }
      ];

      # Imported from https://github.com/cinnyapp/cinny/blob/dev/contrib/nginx/cinny.domain.tld.conf
      locations."/" = {
        root = pkgs.cinny;
        extraConfig = (lib.strings.concatLines [
          "rewrite ^/config.json$ /config.json break;"
          "rewrite ^/manifest.json$ /manifest.json break;"
          "rewrite ^/sw.js$ /sw.js break;"
          "rewrite ^/pdf.worker.min.js$ /pdf.worker.min.js break;"
          "rewrite ^/public/(.*)$ /public/$1 break;"
          "rewrite ^/assets/(.*)$ /assets/$1 break;"
          "rewrite ^(.+)$ /index.html break;"
        ]);
      };

      locations."= /config.json" = {
        alias = ./cinny-config.json;
        extraConfig = ''
          default_type application/json;
        '';
      };
    };

    virtualHosts."element.${config.networking.hostName}.parou.eu" = {
      root = pkgs.element-web;
      addSSL = false;
      forceSSL = false;

      listen = [
        { addr = "127.0.0.1"; port = 8042; }
      ];

      locations."= /config.json" = {
        alias = ./element-config.json;
        extraConfig = ''
          default_type application/json;
        '';
      };
    };
  };
}

