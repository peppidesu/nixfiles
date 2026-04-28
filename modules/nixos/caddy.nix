{lib, config, ...}: {
  options.custom.caddy = {
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
    cfg = config.custom.caddy;
    host = config.networking.hostName;
    mkConfigForAddress = c: c.extraConfig or ''
      reverse_proxy ${c.proxy}
    '';
  in {
    services.caddy.virtualHosts = lib.mkMerge [
      (lib.concatMapAttrs (name: val: {
        "${name}.peppidesu.dev".extraConfig = mkConfigForAddress val;
      }) cfg.publicServices)
      (lib.concatMapAttrs (name: val: {
        "http://${name}.${host}.home.arpa".extraConfig = mkConfigForAddress val;
        "http://${name}.${host}.wg.arpa".extraConfig = mkConfigForAddress val;
      }) (cfg.publicServices // cfg.privateServices))
    ];
  };
}
