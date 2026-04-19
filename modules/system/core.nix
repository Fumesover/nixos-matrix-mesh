{ config, lib, ... }:
let
  cfg = config.my.system.core;
in
{
  options.my.system.core = with lib; {
    i18n.locale = mkOption { type = types.str; default = "en_US.UTF-8"; };

    console = {
      font = mkOption { type = types.str; default = "Lat2-Terminus16"; };
      keyMap = mkOption { type = types.str; default = "us"; };
    };
  };

  config = {
    i18n.defaultLocale = cfg.i18n.locale;

    console = {
      font = cfg.console.font;
      keyMap = cfg.console.keyMap;
    };
  };
}
