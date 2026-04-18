{
  pkgs,
  ...
}: {
  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      listen_addresses = [ "[::]:53" ];
      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        refresh_delay = 72;
      };
      ipv6_servers = true;

      require_nolog = true;
      require_nofilter = true;
      require_dnssec = false;

      cache_size = 65536;
      cache_min_ttl = 2400;
      cache_max_ttl = 604800;
      cache_neg_min_ttl = 30;
      cache_neg_max_ttl = 600;

      cloaking_rules = pkgs.writeText "cloaking-rules.txt" ''
        *.ferry.home.arpa 192.168.1.50
        *.ferry.wg.arpa 10.90.0.1
        *.ferry.wg.arpa fc00:90:90:90::0:1

        *.lagoon.home.arpa 192.168.1.100
        *.lagoon.wg.arpa 10.90.0.2
        *.lagoon.wg.arpa fc00:90:90:90::0:2
      '';
    };
  };
  systemd.services.dnscrypt-proxy.serviceConfig = {
    StateDirectory = "dnscrypt-proxy";
  };  
}
