{lib, config, ...}: {
  options.peppidesu.caddy = {
    publicServices = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
    privateServices = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };
  config = let
    cfg = config.peppidesu.caddy;
    host = config.networking.hostName;
    mkConfigForAddress = c: c.extraConfig or ''
      reverse_proxy ${c.proxy}
    '';
  in {
    services.caddy.virtualHosts = lib.mkMerge [
      (lib.concatMapAttrs (name: val: {
        "${name}.peppidesu.dev".extraConfig = mkConfigForAddress val;
        "${name}.pbbl.dev".extraConfig = mkConfigForAddress val;
      }) cfg.publicServices)
      (lib.concatMapAttrs (name: val: {
        "http://${name}.${host}.reef.arpa".extraConfig = mkConfigForAddress val;
        "http://${name}.${host}.reef".extraConfig = mkConfigForAddress val;
      }) (cfg.publicServices // cfg.privateServices))
    ];
  };
}
