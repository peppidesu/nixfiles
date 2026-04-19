{lib, config, ...}: let
  # Wireguard Home VPN config

  # Subnet sizes for ipv4 and ipv6
  subnet-ipv4 = "16";
  subnet-ipv6 = "64";

  # Peer registry
  peers = {
    ferry = {
      publicKey = "NNeWO/cXpvBci9n/K1W93jKN4wTeHUXZxsELI2XpWQM=";
      privateKeyFile = config.age.secrets.wg-key-ferry.path;
      ipv4 = "10.90.0.1";
      ipv6 = "fc00:90:90:90::0:1";
    };
    lagoon = {
      publicKey = "tpajiBBjNW6RBahfZCttqCxEBu536ZqmuUMzCm93bxI=";
      privateKeyFile = config.age.secrets.wg-key-lagoon.path;
      ipv4 = "10.90.0.2";
      ipv6 = "fc00:90:90:90::0:2";
    };
  };

  # Endpoint peer
  endpoint = "ferry";
  # Endpoint address + port for other peers
  endpointAddress = "wg.peppidesu.dev";
  endpointPort = 51820;

in {
  endpoint = {
    ips = [
      "${peers.${endpoint}.ipv4}/${subnet-ipv4}"
      "${peers.${endpoint}.ipv6}/${subnet-ipv6}"
    ];
    listenPort = endpointPort;
    privateKeyFile = peers.${endpoint}.privateKeyFile;
    peers = builtins.map
      ({value, ...}: {
        allowedIPs = [ "${value.ipv4}/32" "${value.ipv6}/128" ];
        publicKey = value.publicKey;
      })
    (lib.attrsToList (builtins.removeAttrs peers [ endpoint ]));
  };

  peers = (builtins.mapAttrs (name: value: {
    address = [
      "${value.ipv4}/${subnet-ipv4}"
      "${value.ipv6}/${subnet-ipv6}"
    ];
    dns = [
      peers.${endpoint}.ipv4
      peers.${endpoint}.ipv6
    ];
    privateKeyFile = value.privateKeyFile;
    peers = [{
      publicKey = peers.${endpoint}.publicKey;
      allowedIPs = [
        "${peers.${endpoint}.ipv4}/${subnet-ipv4}"
        "${peers.${endpoint}.ipv6}/${subnet-ipv6}"
      ];
      endpoint = "${endpointAddress}:${builtins.toString endpointPort}";
    }];
  }) (builtins.removeAttrs peers [ endpoint ]));

  cloakingRules = builtins.concatStringsSep "\n" (
    builtins.map ({name, value}: ''
      *.${name}.wg.arpa ${value.ipv4}
      *.${name}.wg.arpa ${value.ipv6}
    '') (
      lib.attrsToList peers
    )
  );
}
