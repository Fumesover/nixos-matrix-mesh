{ pkgs, lib, config, ... }:
let
  hostname = config.networking.hostName;
  matrixDomain = "matrix.${hostname}.parou.eu";

  elementConfig = pkgs.writeText "element-config.json" (builtins.toJSON {
    default_server_config = {
      "m.homeserver" = {
        base_url = "https://${matrixDomain}";
        server_name = matrixDomain;
      };
    };
    disable_custom_urls = true;
    disable_guests = true;
    disable_login_language_selector = false;
    disable_3pid_login = false;
    force_verification = false;
    brand = "Element";
    integrations_ui_url = null;
    integrations_rest_url = null;
    integrations_widgets_urls = null;
    default_widget_container_height = 280;
    default_country_code = "CH";
    show_labs_settings = false;
    features = { };
    default_federate = true;
    default_theme = "light";
    room_directory.servers = [ "matrix.org" ];
    enable_presence_by_hs_url = {
      "https://matrix.org" = false;
      "https://matrix-client.matrix.org" = false;
    };
    setting_defaults = {
      breadcrumbs = true;
      "UIFeature.voip" = false;
      "UIFeature.identityServer" = false;
      "UIFeature.locationSharing" = false;
    };
    jitsi = null;
    element_call = null;
    map_style_url = "https://api.maptiler.com/maps/streets/style.json?key=fU3vlMsMn4Jb6dnEIFsx";
  });

  cinnyConfig = pkgs.writeText "cinny-config.json" (builtins.toJSON {
    defaultHomeserver = 0;
    homeserverList = [ matrixDomain ];
    allowCustomHomeservers = false;
    featuredCommunities = {
      openAsDefault = false;
      spaces = [ ];
      rooms = [ ];
      servers = [ ];
    };
    hashRouter = {
      enabled = true;
      basename = "/";
    };
  });
in
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
        alias = cinnyConfig;
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
        alias = elementConfig;
        extraConfig = ''
          default_type application/json;
        '';
      };
    };
  };
}

