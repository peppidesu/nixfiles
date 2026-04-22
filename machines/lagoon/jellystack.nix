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
      services.qbittorrent.serverConfig = {
        Preferences = {
          WebUI = {
            Username = "admin";
            Password_PBKDF2 = "BZ8Whkgga8u8Z1udOhj4sQ==:gHYVcDTgqHSo6/U2IvPBjvlQhYH8Ecv49NNi9A4yZdzTPwgTUaAc8qQ1sR6+WsytoF08hC4YJaI5gtEL41nokA==";
          };
        };
      };

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


      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          # Required for modern Intel GPUs (Xe iGPU and ARC)
          intel-media-driver     # VA-API (iHD) userspace
          vpl-gpu-rt             # oneVPL (QSV) runtime

          # Optional (compute / tooling):
          # intel-compute-runtime  # OpenCL (NEO) + Level Zero for Arc/Xe
        ];
      };
      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "iHD";     # Prefer the modern iHD backend
      };

      hardware.enableRedistributableFirmware = true;
      boot.kernelParams = [ "i915.enable_guc=3" ];
      users.groups.silo = {};
      users.groups.prowlarr = {};

      users.users.jellyfin.extraGroups = [ "video" "render" "silo" ];
      users.users.sonarr.extraGroups = ["silo"];
      users.users.radarr.extraGroups = ["silo"];
      users.users.prowlarr = {
        group = "prowlarr";
        isSystemUser = true;
        extraGroups = ["silo"];
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
