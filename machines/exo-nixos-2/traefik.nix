{ config, ... }:
{
  imports = [
    ./nginx.nix
  ];

  services.traefik = {
    enable = true;

    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
          asDefault = true;
          http.redirections.entrypoint = {
            to = "websecure";
            scheme = "https";
          };
        };

        websecure = {
          address = ":443";
          asDefault = true;
          http.tls.certResolver = "letsencrypt";
        };
      };

      log = {
        level = "INFO";
        filePath = "${config.services.traefik.dataDir}/traefik.log";
        format = "json";
      };

      certificatesResolvers.letsencrypt.acme = {
        email = "postmaster-acme@parou.eu";
        storage = "${config.services.traefik.dataDir}/acme.json";
        httpChallenge.entryPoint = "web";
      };

      api.dashboard = true;
      # Access the Traefik dashboard on <Traefik IP>:8080 of your server
      api.insecure = true;
    };

    dynamicConfigOptions = {
      http.routers.element-exo-parou-eu = {
        rule = "Host(`element.${config.networking.hostName}.parou.eu`)";
        entryPoints = [ "websecure" ];
        service = "nginx-static-service";
        tls.certResolver = "letsencrypt";
      };
      http.routers.cinny-exo-parou-eu = {
        rule = "Host(`cinny.${config.networking.hostName}.parou.eu`)";
        entryPoints = [ "websecure" ];
        service = "nginx-static-service";
        tls.certResolver = "letsencrypt";
      };
      http.routers.matrix-well-known = {
        rule = "Host(`matrix.${config.networking.hostName}.parou.eu`) && PathPrefix(`/.well-known/matrix`)";
        entryPoints = [ "websecure" ];
        service = "nginx-static-service";
        tls.certResolver = "letsencrypt";
        priority = 20;
      };
      http.routers.matrix-exo-parou-eu = {
        rule = "Host(`matrix.${config.networking.hostName}.parou.eu`)";
        entryPoints = [ "websecure" ];
        service = "tuwunel-service";
        tls.certResolver = "letsencrypt";
        priority = 10;
      };

      # Routers
      http.services.nginx-static-service = {
        loadBalancer.passHostHeader = true;
        loadBalancer.servers = [
          { url = "http://127.0.0.1:8042"; }
        ];
      };
      http.services.tuwunel-service = {
        loadBalancer.passHostHeader = true;
        loadBalancer.servers = [
          { url = "http://localhost:6167"; }
        ];
      };
    };
  };
}
