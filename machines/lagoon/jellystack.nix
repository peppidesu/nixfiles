{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  confineServices =
    xs:
    lib.mkMerge (
      [
        {
        }
      ]
      ++ (builtins.map (name: {
        systemd.services.${name}.vpnConfinement = {
          enable = true;
          vpnNamespace = "wgmv";
        };
      }) xs)
    );
in
{
  config = lib.mkMerge [
    {
      peppidesu.caddy = {
        publicServices = {
          "jelly".proxy = "http://localhost:8096";
        };
        privateServices = {
          "jelly".proxy = "http://localhost:8096";
          "seerr.jelly".proxy = "http://10.200.1.1:5055";
          "sonarr.jelly".proxy = "http://10.200.1.1:8989";
          "radarr.jelly".proxy = "http://10.200.1.1:7878";
          "prowlarr.jelly".proxy = "http://10.200.1.1:9696";
          "qbt.jelly".proxy = "http://10.200.1.1:8080";
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
      services.seerr.enable = true;
      services.sonarr.enable = true;
      services.radarr.enable = true;
      services.prowlarr.enable = true;
      services.flaresolverr.enable = true;
      services.qbittorrent.enable = true;
      services.recyclarr.enable = true;


      age.secrets.sonarr-api-key = {
        file = "${inputs.self.outPath}/secrets/sonarr-api-key.age";
        mode = "640";
      };
      age.secrets.sonarr-api-key-raw = {
        file = "${inputs.self.outPath}/secrets/sonarr-api-key-raw.age";
        mode = "640";
      };
      age.secrets.radarr-api-key = {
        file = "${inputs.self.outPath}/secrets/radarr-api-key.age";
        mode = "640";
      };
      age.secrets.radarr-api-key-raw = {
        file = "${inputs.self.outPath}/secrets/radarr-api-key-raw.age";
        mode = "640";
      };

      services.sonarr.environmentFiles = [ config.age.secrets.sonarr-api-key.path ];
      services.radarr.environmentFiles = [ config.age.secrets.radarr-api-key.path ];

      services.recyclarr.configuration = {
        radarr.radarr-main = {
          api_key = {
            _secret = "${config.age.secrets.radarr-api-key-raw.path}";
          };
          base_url = "http://localhost:7878";
          delete_old_custom_formats = true;
          quality_definition.type = "movie";
          quality_profiles = [
            { trash_id = "d1d67249d3890e49bc12e275d989a7e9";  # HD Bluray + WEB
              reset_unmatched_scores.enabled = true; }
            { trash_id = "64fb5f9858489bdac2af690e27c8f42f";  # UHD Bluray + WEB
              reset_unmatched_scores.enabled = true; }
            { trash_id = "722b624f9af1e492284c4bc842153a38";  # Anime Remux
              reset_unmatched_scoress.enabled = true; }
          ];
        };
        sonarr.sonarr-main = {
          api_key = {
            _secret = "${config.age.secrets.sonarr-api-key-raw.path}";
          };
          base_url = "http://localhost:8989";
        };
      };


      services.qbittorrent.serverConfig = {
        Preferences = {
          WebUI = {
            Username = "admin";
            Password_PBKDF2 = "BZ8Whkgga8u8Z1udOhj4sQ==:gHYVcDTgqHSo6/U2IvPBjvlQhYH8Ecv49NNi9A4yZdzTPwgTUaAc8qQ1sR6+WsytoF08hC4YJaI5gtEL41nokA==";
          };
          Downloads = {
            SavePath = "/silo/media/download";
            TempPathEnabled = true;
            TempPath = "/silo/media/download/incomplete";
          };
          Advanced = {
            AnonymousMode = true;
          };
        };
        BitTorrent = {
          Session = {
            AddTorrentStopped = false;
            AnonymousModeEnabled = true;
            GlobalMaxRatio = 2;
            GlobalMaxInactiveSeedingMinutes = 10080;
            ShareLimitAction = "RemoveWithContent";
          };
        };
        Application = {
          MemoryWorkingSetLimit = 1024;
        };

      };

      age.secrets.wg-key-mullvad.file = "${inputs.self.outPath}/secrets/wg-key-mullvad.age";
      vpnNamespaces."wgmv" = {
        enable = true;
        wireguardConfigFile = config.age.secrets.wg-key-mullvad.path;
        namespaceAddress = "10.200.1.1";
        bridgeAddress = "10.200.1.5";
        portMappings = [
          {
            from = 5055;
            to = 5055;
          }
          {
            from = 8989;
            to = 8989;
          }
          {
            from = 7878;
            to = 7878;
          }
          {
            from = 9696;
            to = 9696;
          }
          {
            from = 8080;
            to = 8080;
          }
        ];
      };

      hardware.graphics = {
        enable = lib.mkForce true;
        extraPackages = with pkgs; [
          # Required for modern Intel GPUs (Xe iGPU and ARC)
          intel-media-driver # VA-API (iHD) userspace
          vpl-gpu-rt # oneVPL (QSV) runtime

          # Optional (compute / tooling):
          # intel-compute-runtime  # OpenCL (NEO) + Level Zero for Arc/Xe
        ];
      };
      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "iHD"; # Prefer the modern iHD backend
      };

      hardware.enableRedistributableFirmware = true;
      boot.kernelParams = [ "i915.enable_guc=3" ];
      users.groups.silo = { };
      users.groups.prowlarr = { };

      users.users.jellyfin.extraGroups = [
        "video"
        "render"
        "silo"
      ];
      users.users.sonarr.extraGroups = [ "silo" ];
      users.users.radarr.extraGroups = [ "silo" ];
      users.users.prowlarr = {
        group = "prowlarr";
        isSystemUser = true;
        extraGroups = [ "silo" ];
      };
    }

    # Confine servarr services to VPN namespace
    (confineServices [
      "seerr"
      "sonarr"
      "radarr"
      "prowlarr"
      "flaresolverr"
      "qbittorrent"
      "recyclarr"
    ])
  ];
}
