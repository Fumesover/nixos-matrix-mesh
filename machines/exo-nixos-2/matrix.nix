{ lib, config, pkgs, ... }:
let
  secrets = config.my.secrets;
  hostname = config.networking.hostName;
  localServer = "matrix.${hostname}.parou.eu";

  meshServers = [
    "matrix.nixos-tuwumesh-1.parou.eu"
    "matrix.nixos-tuwumesh-2.parou.eu"
    "matrix.nixos-tuwumesh-3.parou.eu"
    "matrix.nixos-tuwumesh-4.parou.eu"
  ];
  peerServers = builtins.filter (s: s != localServer) meshServers;

  replicatorScript = pkgs.writeShellScript "matrix-replicator" ''
    set -euo pipefail

    ENDPOINT="http://localhost:6167"
    LOCAL_SERVER="${localServer}"
    REPLICATOR="@replicator:''${LOCAL_SERVER}"
    AUTH="Authorization: Bearer $(cat /var/lib/tuwunel/replicator-token)"

    # Rooms the replicator has already joined
    JOINED=$(${pkgs.curl}/bin/curl -sf -H "''${AUTH}" \
      "''${ENDPOINT}/_matrix/client/v3/joined_rooms" \
      | ${pkgs.jq}/bin/jq -r '.joined_rooms[]')

    for PEER in ${lib.escapeShellArgs peerServers}; do
      echo "Querying rooms from ''${PEER}..."

      ROOMS=$(${pkgs.curl}/bin/curl -sf -H "''${AUTH}" \
        "''${ENDPOINT}/_matrix/client/v3/publicRooms?server=''${PEER}" \
        | ${pkgs.jq}/bin/jq -r '.chunk[].room_id // empty') || continue

      for ROOM in ''${ROOMS}; do
        if ! echo "''${JOINED}" | grep -qxF "''${ROOM}"; then
          echo "Joining ''${ROOM} from ''${PEER}"
          ${pkgs.curl}/bin/curl -sf -X POST \
            -H "''${AUTH}" -H "Content-Type: application/json" \
            -d "{\"user_id\": \"''${REPLICATOR}\"}" \
            "''${ENDPOINT}/_synapse/admin/v1/join/''${ROOM}" || true
        fi
      done
    done

    echo "Replication sync complete."
  '';
in
{
  # Allow tuwunel to read matrix-appservice-irc's files
  # users.users.matrix-tuwunel.extraGroups = [ "matrix-appservice-irc" ];

  # Hijacking the systemd service to force create the database backup dir
  systemd.services."tuwunel".serviceConfig = {
    StateDirectory = lib.mkForce "tuwunel tuwunel/backups";
  };

  services.matrix-tuwunel = {
    enable = true;

    settings.global = {
      server_name = "matrix.${config.networking.hostName}.parou.eu";
      allow_registration = true;
      allow_federation = true;
      allowed_remote_server_names_experimental = [
        "matrix\\.nixos-tuwumesh-[1234]\\.parou\\.eu"
      ];
      allow_encryption = true;
      registration_token = secrets.services.matrix.registration_token;
      new_user_displayname_suffix = "";
      database_backups_to_keep = 7;

      appservice_config_files = [
        # auto-register irc bridge
        # "/var/lib/matrix-appservice-irc/registration.yml"
      ];

      database_backup_path = "/var/lib/tuwunel/backups";
    };
  };

  # services.matrix-appservice-irc = {
  #   enable = true;
  #   registrationUrl = "http://localhost:8009";

  #   settings = {
  #     homeserver = {
  #       url = "http://localhost:${builtins.toString (builtins.head config.services.matrix-tuwunel.settings.global.port)}";
  #       domain = "matrix.${config.networking.hostName}.parou.eu";
  #     };

  #     ircService.logging.level = "info"; # Do not log messages
  #     ircService.mediaProxy = {
  #       publicUrl = "https://matrix.${config.networking.hostName}.parou.eu/irc-media";
  #       bindPort = 11111;
  #       ttlSeconds = 0;
  #     };
  #     ircService.servers = {
  #       "irc.exoscale.ch" = {
  #         name = "Exoscale IRC server";
  #         port = 6697;
  #         ssl = true;

  #         ircClients.nickTemplate = "$DISPLAY";
  #         ircClients.lineLimit = 42;

  #         botConfig.enabled = true;
  #         botConfig.nick     = secrets.services.matrix.bot_name;
  #         botConfig.username = secrets.services.matrix.bot_name;
  #         botConfig.password = secrets.services.matrix.bot_password;
  #         allowUserConfig = true;
  #         sayName = false;
  #         # sasl = true;

  #         # Allow users to join any channel
  #         dynamicChannels = {
  #           enabled = true;
  #           federate = false;
  #         };
  #         membershipLists = {
  #           enabled = true;
  #           global.ircToMatrix.initial = true;
  #           global.ircToMatrix.incremental = true;
  #           global.matrixToIrc.initial = true;
  #           global.matrixToIrc.incremental = true;
  #         };
  #       };
  #     };
  #   };
  # };

  # # custom systemd timer which forces all rooms to have "shared" visibility,
  # # allowing newjoiners to access history
  # systemd.services.matrix-appservice-irc-force-shared = {
  #   startAt = "hourly";
  #   script = ''
  #     #! /usr/bin/env bash

  #     set -eo pipefail

  #     ENDPOINT="http://localhost:6167"
  #     AUTH="Authorization: Bearer $(${pkgs.yq}/bin/yq -r .as_token /var/lib/matrix-appservice-irc/registration.yml)"

  #     while read -r ROOM ; do
  #       VISIBILITY="$(curl -s --fail -XGET -H "$AUTH" "$ENDPOINT/_matrix/client/v3/rooms/$ROOM/state/m.room.history_visibility" | ${pkgs.jq}/bin/jq -r .history_visibility)"
  #       echo "ROOM: $ROOM : $VISIBILITY"

  #       if [ "$VISIBILITY" != "shared" ]; then
  #               echo "ROOM: Making $ROOM shared"
  #               curl -s --fail -XPUT -d '{"history_visibility": "shared"}' -H "$AUTH" "$ENDPOINT/_matrix/client/v3/rooms/$ROOM/state/m.room.history_visibility"
  #       fi

  #     done < <(curl -s --fail -XGET -H "$AUTH" $ENDPOINT/_matrix/client/v3/joined_rooms | ${pkgs.jq}/bin/jq -r .joined_rooms[])
  #     '';

  #   serviceConfig = {
  #     Type = "oneshot";
  #     User = "matrix-appservice-irc";
  #   };
  # };

  # Replicator: ensures every room in the mesh is federated to this node
  # by having a local @replicator user join all public rooms from peer servers.
  #
  # Setup: register a `replicator` user on each node, make it admin, and
  # store its access token in /var/lib/tuwunel/replicator-token
  systemd.services.matrix-replicator = {
    description = "Matrix mesh room replicator";
    after = [ "tuwunel.service" ];
    requires = [ "tuwunel.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = replicatorScript;
      User = "matrix-tuwunel";
    };
  };

  systemd.timers.matrix-replicator = {
    description = "Run matrix mesh replicator every 5 minutes";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "5min";
    };
  };
}

