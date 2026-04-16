{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      sources.public-resolvers = {
        urls = [ "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md" ];
        cache_file = "/var/lib/dnscrypt-proxy/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        refresh_delay = 72;
      };
      ipv6_servers = true;

      require_nolog = true;
      require_nofilter = true;
      require_dnssec = false;

      cloaking_rules = pkgs.writeText "cloaking-rules.txt" ''
        *.ferry.wg.arpa 10.90.0.1
        *.ferry.wg.arpa fc00:90:90:90::0:1
        *.lagoon.wg.arpa 10.90.0.2
        *.lagoon.wg.arpa fc00:90:90:90::0:2
      '';
    };
  };
}
