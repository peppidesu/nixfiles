{ config, lib, pkgs, ... }:

let
  cfg = config.programs.nwg-drawer;

  # Map config keys -> CLI flags accepted by nwg-drawer.
  # Extend freely; any unlisted key is passed through as --key value.
  flags = {
    terminal     = "-term";
    file-manager = "-fm";
    language     = "-lang";
    columns      = "-c";
    icon-size    = "-is";
    spacing      = "-spacing";
    gtk-theme    = "-g";
    icon-theme   = "-i";
    css-file     = "-s";
  };

  # Build CLI args from cfg.settings (preserving declared key order).
  args = lib.concatLists (lib.mapAttrsToList (name: value:
    let flag = flags.${name} or "--${name}";
    in if builtins.isBool value
       then lib.optional value flag          # e.g. --noactions
       else [ flag (toString value) ]
  ) cfg.settings);

  drawerWrapper = pkgs.writeShellScriptBin "nwg-drawer" ''
    exec ${lib.getExe cfg.package} ${
      lib.concatStringsSep " " (map lib.escapeShellArg args)
    } "$@"
  '';
in {
  options.programs.nwg-drawer = {
    enable = lib.mkEnableOption "nwg-drawer, a GTK application launcher for wlroots compositors";

    package = lib.mkPackageOption pkgs "nwg-drawer" { };

    settings = lib.mkOption {
      type = with lib.types; attrsOf (oneOf [ bool int str ]);
      default = { };
      example = {
        terminal     = "foot";
        file-manager = "thunar";
        columns      = 6;
        icon-size    = 48;
        spacing      = 24;
      };
      description = ''
        Options passed to nwg-drawer as CLI flags on every launch.
      '';
    };

    style = lib.mkOption {
      type = lib.types.nullOr lib.types.lines;
      default = null;
      description = ''
        CSS stylesheet written to ~/.config/nwg-drawer/drawer.css.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ drawerWrapper ];

    xdg.configFile = lib.mkIf (cfg.style != null) {
      "nwg-drawer/drawer.css".text = cfg.style;
    };
  };
}
