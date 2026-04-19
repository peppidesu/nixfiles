{
  inputs,
  config,
  pkgs,
  ...
}: {
  # jellyfin
  services.jellyfin.enable = true;
  services.caddy.virtualHosts."jelly.peppidesu.dev" = {
    extraConfig = ''
      reverse_proxy http://localhost:8089
    '';
  };

  age.secrets.wg-key-mullvad.file = "${inputs.self.outPath}/secrets/wg-key-mullvad.age";
  networking.wg-quick.interfaces.wgmv = {
    address = [
      "10.64.108.27/32"
      "fc00:bbbb:bbbb:bb01::1:6c1a/128"
    ];
    dns = [ "10.64.0.1" ];
    privateKeyFile = config.age.secrets.wg-key-mullvad.path;
    peers = [{
      publicKey = "Qn1QaXYTJJSmJSMw18CGdnFiVM0/Gj/15OdkxbXCSG0=";
      allowedIPs = [ "0.0.0.0/0" "::0/0" ];
      endpoint = "193.32.249.66:3002";
    }];
  };
  systemd.services.wgmv-ns-setup = {
    description = "Move WireGuard wgmv into namespace wgmv";
    wants = [ "wg-quick@wgmv.service" ];
    after = [ "wg-quick@wgmv.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.ExecStart = pkgs.writeShellApplication {
      name = "move-wgmv-to-namespace";
      runtimeInputs = [ pkgs.iproute2 ];

      text = ''
        if ! ip netns list | grep -q '^myns$'; then
          ip netns add myns
        fi
        ip link set wgmv netns wgmv
        mkdir -p /etc/netns/wgmv
        cp /etc/resolv.conf /etc/netns/wgmv/resolv.conf
      '';
    };
  };

  # servarr
  services.jellyseerr.enable = true;
  systemd.services.jellyseerr.serviceConfig.NetworkNamespacePath = "/run/netns/wgmv";
  services.sonarr.enable = true;
  systemd.services.sonarr.serviceConfig.NetworkNamespacePath = "/run/netns/wgmv";
  services.radarr.enable = true;
  systemd.services.radarr.serviceConfig.NetworkNamespacePath = "/run/netns/wgmv";
  services.prowlarr.enable = true;
  systemd.services.prowlarr.serviceConfig.NetworkNamespacePath = "/run/netns/wgmv";
  services.flaresolverr.enable = true;
  systemd.services.flaresolverr.serviceConfig.NetworkNamespacePath = "/run/netns/wgmv";
  services.qbittorrent.enable = true;
  systemd.services.qbittorrent.serviceConfig.NetworkNamespacePath = "/run/netns/wgmv";
}
