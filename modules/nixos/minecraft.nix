{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkOption mkEnableOption types literalExpression optionalAttrs;
  cfg = config.services.mc-modded;

  mcVersion = builtins.replaceStrings [ "." ] [ "_" ] cfg.minecraftVersion;

  # One Modrinth file -> a store path whose basename is the real jar filename,
  # so linkFarmFromDrvs symlinks it into mods/ with the correct name.
  modDrv = m: pkgs.fetchurl {
    name = m.file;
    url = "https://cdn.modrinth.com/data/${m.project}/versions/${m.version}/${m.file}";
    inherit (m) hash;
  };

  modsDir = pkgs.linkFarmFromDrvs "mods-${cfg.name}"
    (map modDrv cfg.mods ++ cfg.extraMods);

  serverPackage =
    if cfg.java.override then cfg.package.override { jre_headless = cfg.java.package; }
    else cfg.package;
in
{
  options.services.mc-modded = {
    enable = mkEnableOption "a modded Minecraft server populated from Modrinth";

    name = mkOption {
      type = types.strMatching "[A-Za-z0-9_-]+";
      default = "main";
      description = "Server name: systemd unit, data dir and tmux socket name.";
    };

    minecraftVersion = mkOption {
      type = types.str;
      default = "26.3";
      example = "1.21.1";
      description = "Minecraft version, e.g. \"26.3\" or \"1.21.1\".";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.fabricServers."fabric-${mcVersion}";
      defaultText = literalExpression ''pkgs.fabricServers."fabric-''${minecraftVersion}"'';
      example = literalExpression ''pkgs.neoforgeServers."neoforge-1_21_1"'';
      description = "Server software. Defaults to the Fabric server for `minecraftVersion`.";
    };

    java = {
      override = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to force the server derivation to use `java.package`.
          Needed because nix-minecraft can pick the wrong JRE for the new
          year-based versions (26.x), which require Java 25.
        '';
      };
      package = mkOption {
        type = types.package;
        default = pkgs.openjdk25_headless;
        description = "JRE used to run the server.";
      };
    };

    mods = mkOption {
      type = types.listOf (types.submodule {
        options = {
          project = mkOption {
            type = types.str;
            example = "gvQqBUqZ";
            description = "Modrinth project ID (the base62 slug in the CDN URL).";
          };
          version = mkOption {
            type = types.str;
            example = "M7RXiitG";
            description = "Modrinth version ID (pinned, not a version number).";
          };
          file = mkOption {
            type = types.str;
            example = "lithium-fabric-mc1.21.9-0.15.3.jar";
            description = "Exact filename from the version's download URL.";
          };
          hash = mkOption {
            type = types.str;
            example = "sha512-...";
            description = "SRI hash of the jar, from nix-modrinth-prefetch.";
          };
        };
      });
      default = [ ];
      description = "Mods fetched from Modrinth and symlinked into `mods/`.";
    };

    extraMods = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional jars (derivations/paths) to drop into `mods/`.";
    };

    port = mkOption { type = types.port; default = 25565; };
    openFirewall = mkOption { type = types.bool; default = false; };

    jvmOpts = mkOption {
      type = types.str;
      default = "-Xms4G -Xmx6G";
      example = "-Xms8G -Xmx8G -XX:+UseG1GC";
    };

    serverProperties = mkOption {
      type = types.attrs;
      default = { };
      example = literalExpression ''
        {
          motd = "modded nixos server";
          difficulty = "hard";
          view-distance = 12;
          simulation-distance = 10;
          white-list = true;
        }
      '';
      description = "Entries for server.properties (merged over defaults).";
    };

    whitelist = mkOption {
      type = types.nullOr (types.attrsOf types.str);
      default = null;
      example = { alice = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"; };
      description = "Username -> UUID map; null leaves whitelist unmanaged.";
    };

    operators = mkOption {
      type = types.nullOr types.attrs;
      default = null;
      example = { alice = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"; };
    };

    files = mkOption {
      type = types.attrs;
      default = { };
      example = literalExpression ''
        {
          "config/some-mod.json".value = { enabled = true; };
        }
      '';
      description = "Files copied into the server dir (writable configs).";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true; # minecraft server is unfree

    services.minecraft-servers = {
      enable = true;
      eula = true;

      servers.${cfg.name} = {
        enable = true;
        package = serverPackage;
        jvmOpts = cfg.jvmOpts;
        openFirewall = cfg.openFirewall;
        enableReload = true; # re-link mods/config on `nixos-rebuild switch`

        serverProperties = cfg.serverProperties // { server-port = cfg.port; };

        symlinks.mods = modsDir;
        files = cfg.files;
      }
      // optionalAttrs (cfg.whitelist != null) { whitelist = cfg.whitelist; }
      // optionalAttrs (cfg.operators != null) { operators = cfg.operators; };
    };
  };
}
