{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let

  confineServices = xs: lib.mkMerge ([{
  }] ++ (builtins.map (name: {
    systemd.services.${name}.vpnConfinement = {
      enable = true;
      vpnNamespace = "wgmv";
    };
  }) xs));

  makeCaddyConfig = { publicServices, privateServices }: let
    makeVirtualHostConfig = cfg: cfg.extraConfig or "reverse_proxy ${cfg.proxy}";
  in lib.mkMerge [
    (lib.concatMapAttrs (name: value: {
      "${name}.peppidesu.dev".extraConfig = makeVirtualHostConfig value;
    }) publicServices)
    (lib.concatMapAttrs (name: value: {
      "http://${name}.lagoon.home.arpa".extraConfig = makeVirtualHostConfig value;
      "http://${name}.lagoon.wg.arpa".extraConfig = makeVirtualHostConfig value;
    }) (publicServices // privateServices))
  ];
in {
  config = lib.mkMerge [
    {
      services.caddy.virtualHosts = makeCaddyConfig {
        publicServices = {
          "jelly".proxy = "http://localhost:8096";
        };
        privateServices = {
          "seerr".proxy = "http://10.200.1.1:5055";
          "sonarr".proxy = "http://10.200.1.1:8989";
          "radarr".proxy = "http://10.200.1.1:7878";
          "prowlarr".proxy = "http://10.200.1.1:9696";
          "qbt".proxy = "http://10.200.1.1:8080";
        };
      };
      # jellyfin
      services.jellyfin = {
        enable = true;
        configDir = "/opt/jellyfin/config";
        dataDir = "/opt/jellyfin/data";
        cacheDir = "/opt/jellyfin/cache";
      };

      # servarr
      services.jellyseerr.enable = true;
      services.sonarr.enable = true;
      services.radarr.enable = true;
      services.prowlarr.enable = true;
      services.flaresolverr.enable = true;
      services.qbittorrent.enable = true;

      age.secrets.wg-key-mullvad.file = "${inputs.self.outPath}/secrets/wg-key-mullvad.age";
      vpnNamespaces."wgmv" = {
        enable = true;
        wireguardConfigFile = config.age.secrets.wg-key-mullvad.path;
        namespaceAddress = "10.200.1.1";
        bridgeAddress = "10.200.1.5";
        portMappings = [
          { from = 5055; to = 5055; }
          { from = 8989; to = 8989; }
          { from = 7878; to = 7878; }
          { from = 9696; to = 9696; }
          { from = 8080; to = 8080; }
        ];
      };
    }

    # Confine servarr services to VPN namespace
    (confineServices [
      "jellyseerr"
      "sonarr"
      "radarr"
      "prowlarr"
      "flaresolverr"
      "qbittorrent"
    ])
  ];
}
