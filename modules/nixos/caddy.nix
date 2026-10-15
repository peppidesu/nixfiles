{ lib, config, ... }: {
  options.peppidesu.caddy = {
    publicServices = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
    privateServices = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };
  config =
    let
      cfg = config.peppidesu.caddy;
      mkConfigForAddress =
        c:
        c.extraConfig or ''
          reverse_proxy ${c.proxy}
        '';
    in
    {
      services.caddy.virtualHosts = lib.mkMerge [
        (lib.concatMapAttrs (name: val: {
          "${name}.peppidesu.dev".extraConfig = mkConfigForAddress val;
          "${name}.pbbl.dev".extraConfig = mkConfigForAddress val;
        }) cfg.publicServices)
        (lib.concatMapAttrs (name: val: {
          "http://${name}.reef".extraConfig = mkConfigForAddress val;
        }) cfg.privateServices)
      ];
    };
}
