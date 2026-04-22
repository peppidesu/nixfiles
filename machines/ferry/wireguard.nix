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

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
    # This is the important part:
    extraCommands = ''
      iptables -A FORWARD -i wg0 -o wg0 -j ACCEPT
      iptables -A FORWARD -i wg0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
      iptables -A FORWARD -o wg0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    '';

    extraStopCommands = ''
      iptables -D FORWARD -i wg0 -o wg0 -j ACCEPT || true
      iptables -D FORWARD -i wg0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT || true
      iptables -D FORWARD -o wg0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT || true
    '';
  };
}
