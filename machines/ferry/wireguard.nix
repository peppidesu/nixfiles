 {lib, inputs, config, ...}: {
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

   networking.wireguard.interfaces = {
     wg0 = {
       ips = [ "10.90.0.1/16" "fc00:90:90:90::0:1/64" ];
       listenPort = 51820;
       privateKeyFile = config.age.secrets.wg-key-ferry.path;

       peers = [
         {
           publicKey = "tpajiBBjNW6RBahfZCttqCxEBu536ZqmuUMzCm93bxI=";
           allowedIPs = [ "10.90.0.2/32" "fc00:90:90:90::0:2/128" ];
         }
       ];
     };
   };

  systemd.services = lib.concatMapAttrs (name: _: {
    "wireguard-${name}".serviceConfig = {
      User = "wireguard";
      Group = "wireguard";
      AmbientCapabilities = "CAP_NET_ADMIN";
    };
  }) config.networking.wireguard.interfaces;
}
