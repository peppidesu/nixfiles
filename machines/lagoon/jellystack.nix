{
  inputs,
  config,
  ...
}: {
  # jellyfin
  services.jellyfin.enable = true;
  services.caddy.virtualHosts."jelly.peppidesu.dev" = {
    extraConfig = ''
      reverse_proxy http://localhost:8089
    '';
  };

  age.secrets.wg-key-mullvad-server.file = "${inputs.self.outPath}/secrets/wg-key-mullvad-server.age";
  networking.wg-quick.interfaces.wg-mullvad = {
    address = [
      "10.64.108.27/32"
      "fc00:bbbb:bbbb:bb01::1:6c1a/128"
    ];
    dns = [ "10.64.0.1" ];
    privateKeyFile = config.age.secrets.wg-key-mullvad-server.path;
    peers = [{
      publicKey = "Qn1QaXYTJJSmJSMw18CGdnFiVM0/Gj/15OdkxbXCSG0=";
      allowedIPs = [ "0.0.0.0/0" "::0/0" ];
      endpoint = "193.32.249.66:3002";
    }];
  };
  systemd.services.wgmv-ns-setup = {
    description = "Move WireGuard wg-mullvad into namespace wgmv";
    wants = [ "wg-quick@wg-mullvad.service" ];
    after = [ "wg-quick@wg-mullvad.service" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.ExecStart = ''
      ip netns add wgmv || true
      ip link set wg-mullvad netns wgmv
      mkdir -p /etc/netns/wgmv
      cp /etc/resolv.conf /etc/netns/wgmv/resolv.conf
    '';
    install.WantedBy = [ "multi-user.target" ];
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
