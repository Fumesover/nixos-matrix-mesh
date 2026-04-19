{ lib, ... }:

with builtins;
with lib;
let
  throwOnCanary =
    let
      canaryHash = builtins.hashFile "sha256" ./canary;
      expectedHash = "37e83b249d1fd8ef1966d3205c9f0fd8c802de91b02b0f9b6e506a33350a7525";
    in
    if canaryHash != expectedHash
    then throw "Secrets are not readable. Have you run `git crypt unlock` ? Expected ${expectedHash} but got ${canaryHash}"
    else id;
in
throwOnCanary {
  options.my.secrets = mkOption {
    type =
      let
        self = with types; oneOf [
          int
          str
          (listOf str)
          (attrsOf self)
        ];
      in
      self;
  };

  config.my.secrets = {
    services = {
      matrix = {
        registration_token = lib.trim (fileContents ./services/matrix/registration_token);
        bot_name     = lib.trim (fileContents ./services/matrix/bot_name);
        bot_password = lib.trim (fileContents ./services/matrix/bot_password);
      };
    };
    users = {
      fumesover = {
        authorizedKeys = lib.splitString "\n" (fileContents ./users/fumesover/authorized_keys);
      };
    };
  };
}
