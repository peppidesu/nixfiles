moduleArgs@{
  pkgs,
  lib,
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
      server_names = [ "quad9-dnscrypt-ip4-filter-pri" "quad9-dnscrypt-ip4-nofilter-pri" ];
      ipv6_servers = false;

      require_nolog = true;
      require_nofilter = false;
      require_dnssec = false;

      cache_size = 16384;

      cloaking_rules = pkgs.writeText "cloaking-rules.txt" ''
        ${(import ../../common/wg.nix moduleArgs).cloakingRules}
      '';
    };
  };
  networking.firewall = {
    allowedUDPPorts = [ 53 ];
  };
  systemd.services.dnscrypt-proxy.serviceConfig = {
    StateDirectory = "dnscrypt-proxy";
  };
}
