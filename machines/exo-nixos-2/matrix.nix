{ lib, config, pkgs, ... }:
let
  secrets = config.my.secrets;
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
      server_name = "matrix.exo.parou.eu";
      allow_registration = true;
      allow_federation = false;
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

  services.matrix-appservice-irc = {
    enable = true;
    registrationUrl = "http://localhost:8009";

    settings = {
      homeserver = {
        url = "http://localhost:${builtins.toString (builtins.head config.services.matrix-tuwunel.settings.global.port)}";
        domain = "matrix.exo.parou.eu";
      };

      ircService.logging.level = "info"; # Do not log messages
      ircService.mediaProxy = {
        publicUrl = "https://matrix.exo.parou.eu/irc-media";
        bindPort = 11111;
        ttlSeconds = 0;
      };
      ircService.servers = {
        "irc.exoscale.ch" = {
          name = "Exoscale IRC server";
          port = 6697;
          ssl = true;

          ircClients.nickTemplate = "$DISPLAY";
          ircClients.lineLimit = 42;

          botConfig.enabled = true;
          botConfig.nick     = secrets.services.matrix.bot_name;
          botConfig.username = secrets.services.matrix.bot_name;
          botConfig.password = secrets.services.matrix.bot_password;
          allowUserConfig = true;
          sayName = false;
          # sasl = true;

          # Allow users to join any channel
          dynamicChannels = {
            enabled = true;
            federate = false;
          };
          membershipLists = {
            enabled = true;
            global.ircToMatrix.initial = true;
            global.ircToMatrix.incremental = true;
            global.matrixToIrc.initial = true;
            global.matrixToIrc.incremental = true;
          };
        };
      };
    };
  };

  # custom systemd timer which forces all rooms to have "shared" visibility,
  # allowing newjoiners to access history
  systemd.services.matrix-appservice-irc-force-shared = {
    startAt = "hourly";
    script = pkgs.writeShellScript ''
      #! /usr/bin/env bash

      set -eo pipefail

      ENDPOINT="http://localhost:6167"
      AUTH='Authorization: Bearer $(${pkgs.yq}/bin/yq -r .as_token /var/lib/matrix-appservice-irc/registration.yml)'

      while read -r ROOM ; do
        VISIBILITY=$(curl -s --fail -XGET -H "$AUTH" "$ENDPOINT/_matrix/client/v3/rooms/$ROOM/state/m.room.history_visibility" | $JQ -r .history_visibility)
        echo "ROOM: $ROOM : $VISIBILITY"

        if [ "$VISIBILITY" != "shared" ]; then
                echo "ROOM: Making $ROOM shared"
                curl -s --fail -XPUT -d '{"history_visibility": "shared"}' -H "$AUTH" "$ENDPOINT/_matrix/client/v3/rooms/$ROOM/state/m.room.history_visibility"
        fi

      done < <(curl -s --fail -XGET -H "$AUTH" $ENDPOINT/_matrix/client/v3/joined_rooms | $JQ -r .joined_rooms[])
      '';

    serviceConfig = {
      Type = "oneshot";
      User = "matrix-appservice-irc";
    };
  };
}

