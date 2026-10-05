let
  lagoon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINwFC0NHKRy8ceAQWdxGHncauk7zf0UWQSaQsR1pF73k root@lagoon";
  ferry = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBJKQeBymU0nYPFrA2dJ4QMfhYQb7BqR6N34HxjJBDQS root@ferry";
  megalodon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKWJhhMtAPrXT5JBX8AUaeQAIuPLjs/MEuEA4NLFKvnx root@megalodon";
  archelon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAE6R5oK0crQGOOvGkhhjWMTU5WBpc0JQee8bzVwVOOZ root@archelon";
  peppidesu-dreadnought = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO97Yve7hz7krbWA2FOgEihMAoGNmb2PhiwrUB3vXPzS peppidesu@dreadnought";
  peppidesu-archelon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHDmqN9vOXKI8lgVdmUQF2Bg7yZ6lz5tNZmSJN+syr1w peppidesu@archelon";
in
{
  # Wireguard private key for Mullvad VPN
  "wg-key-mullvad.age".publicKeys = [
    lagoon
    peppidesu-dreadnought
    peppidesu-archelon
  ];

  # Wireguard private key for archelon.reef
  # Public key: YoBsqGw7+NXDqW66Vc6N+otiSoCFRtr3c58Ih+wbPg8=
  # "wg-key-archelon.age".publicKeys = [ peppidesu-dreadnought ];

  # Wireguard private key for lagoon.reef
  # Public key: tpajiBBjNW6RBahfZCttqCxEBu536ZqmuUMzCm93bxI=
  "wg-key-lagoon.age".publicKeys = [
    lagoon
    peppidesu-dreadnought
    peppidesu-archelon
  ];

  # Wireguard private keys for ferry.reef
  # Public key: NNeWO/cXpvBci9n/K1W93jKN4wTeHUXZxsELI2XpWQM=
  "wg-key-ferry.age".publicKeys = [
    ferry
    peppidesu-dreadnought
    peppidesu-archelon
  ];

  "factorio-token.age".publicKeys = [
    lagoon
    peppidesu-dreadnought
    peppidesu-archelon
  ];

  "attic-anemone.age".publicKeys = [
    archelon
    megalodon
    peppidesu-dreadnought
    peppidesu-archelon
  ];
}
