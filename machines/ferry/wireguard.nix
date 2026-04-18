 moduleArgs@{lib, inputs, config, ...}: {
   # Create system user for wireguard services
   users.users.wireguard = {
     isSystemUser = true;
     group = "wireguard";
   };
   users.groups."wireguard" = {};

   age.secrets.wg-key-ferry = {
     file = "${inputs.self.outPath}/secrets/wg-key-ferry.age";
     mode = "600";
     owner = "wireguard";
     group = "wireguard";
   };

  networking.wireguard.interfaces.wg0 = (import ../../common/wg.nix moduleArgs).endpoint;

  systemd.services = lib.concatMapAttrs (name: value: {
    "wireguard-${name}".serviceConfig = {
      User = "wireguard";
      Group = "wireguard";
      AmbientCapabilities = "CAP_NET_ADMIN";
    };
  }) config.networking.wireguard.interfaces;
}
