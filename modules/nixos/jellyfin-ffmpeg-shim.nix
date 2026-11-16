{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkOption mkEnableOption mkDefault mkForce types;
  cfg = config.services.jellyfin-ffmpeg-shim;
  jellyfin = config.services.jellyfin;

  runtimeDir = "/run/jellyfin-ffmpeg-shim";
  runtimeConfig = "${runtimeDir}/shim.json";

  # Mirrors shim.json.example; overridden/merged by cfg.settings.
  defaults = {
    shim = {
      kill_switch = false;
      enable_hdr_to_hdr = true;
      enable_bitrate_min = true;
      enable_client_allow_deny = false;
      enable_filter_complex_hdr_to_hdr = true;
      enable_opencl_subtitle_compositor = true;
      enable_diagnostic_overlay = false;
      log_full_argv = false;
    };
    jellyfin = {
      url = "http://127.0.0.1:8096";
      api_key = "";
    };
    paths = {
      ffmpeg_binary = "${cfg.ffmpegPackage}/bin/ffmpeg";
      ffprobe_binary = "${cfg.ffmpegPackage}/bin/ffprobe";
      log_file = cfg.logFile;
    };
    tuning = {
      minrate_ratio = 0.7;
      diagnostic_overlay_duration_seconds = 15.0;
      blocking_decision_poll_delays_seconds = [ 0.0 0.25 0.75 1.5 2.5 ];
      blocking_decision_api_timeout_seconds = 1.0;
      source_probe_timeout_seconds = 2.0;
    };
    hdr_access = {
      allow_list = [ ];
      deny_list = [ ];
    };
  };

  merged = lib.recursiveUpdate defaults cfg.settings;

  configJson = pkgs.writeText "jellyfin-shim.json" (builtins.toJSON merged);

  effectiveConfig = if cfg.apiKeyFile == null then configJson else runtimeConfig;

  jellyfinWithShim = cfg.jellyfinPackage.override { jellyfin-ffmpeg = cfg.package; };


in
{
  options.services.jellyfin-ffmpeg-shim = {
    enable = mkEnableOption "the jellyfin-ffmpeg HDR shim";

    package = mkOption {
      type = types.package;
      default = pkgs.jellyfin-ffmpeg-shim;
      description = "The jellyfin-ffmpeg-shim package (overlay/flake provides this).";
    };

    jellyfinPackage = mkOption {
      type = types.package;
      default = pkgs.jellyfin;
      description = "The Jellyfin package to wrap with the shim.";
    };

    ffmpegPackage = mkOption {
      type = types.package;
      default = pkgs.jellyfin-ffmpeg;
      description = ''
        FFmpeg build the shim execs and probes with. Upstream nixpkgs
        `jellyfin-ffmpeg` lacks the custom `overlay_p010_bgra_opencl` filter, so
        the shim will use its software subtitle fallback. Point this at a build
        of https://github.com/bjlaur/jellyfin-ffmpeg for the zero-copy path.
      '';
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      example = {
        shim.enable_client_allow_deny = true;
        hdr_access.allow_list = [ { username = "alex"; devices = [ "living room tv" ]; } ];
      };
      description = ''
        Recursively merged over the shipped defaults. `paths.*` are filled in
        from {option}`ffmpegPackage` / {option}`logFile`; override explicitly
        only if you know what you are doing.
      '';
    };

    logFile = mkOption {
      type = types.str;
      default = "${jellyfin.logDir}/jellyfin-ffmpeg-shim.log";
      defaultText = lib.literalExpression ''"''${config.services.jellyfin.logDir}/jellyfin-ffmpeg-shim.log"'';
      description = "Writable path the shim appends its decision log to.";
    };

    apiKeyFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        File containing the Jellyfin API key. Prefer this over
        `settings.jellyfin.api_key`, which would end up world-readable in the
        Nix store. Required when `enable_client_allow_deny` is true, otherwise
        the shim forces its kill switch.
      '';
    };

    integrate = mkOption {
      type = types.bool;
      default = true;
      description = "Point Jellyfin at the shim via {option}`services.jellyfin.package`.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = jellyfin.enable;
        message = "services.jellyfin-ffmpeg-shim requires services.jellyfin.enable = true.";
      }
    ];

    warnings = lib.optional
      (cfg.apiKeyFile == null && (merged.shim.enable_client_allow_deny or false))
      "services.jellyfin-ffmpeg-shim: enable_client_allow_deny is true but no apiKeyFile is set; the shim will pass everything through.";

    # Normal case: symlink the generated JSON into /etc.
    environment.etc."jellyfin/shim.json" = mkIf (cfg.apiKeyFile == null) {
      source = configJson;
      mode = "0644";
    };

    systemd.services.jellyfin = {
      environment.JELLYFIN_SHIM_CONFIG = toString effectiveConfig;

      serviceConfig = mkIf (cfg.apiKeyFile != null) {
        RuntimeDirectory = [ "jellyfin-ffmpeg-shim" ];
        RuntimeDirectoryMode = "0700";
      };

      # Merge the secret into the config at start time so it never hits the store.
      preStart = mkIf (cfg.apiKeyFile != null) (lib.mkAfter ''
        umask 0077
        ${lib.getExe pkgs.jq} --arg key "$(cat ${cfg.apiKeyFile})" \
          '.jellyfin.api_key = $key' ${configJson} > ${runtimeConfig}
      '');
    };

    services.jellyfin.package = mkIf cfg.integrate (mkDefault jellyfinWithShim);
  };
}
