{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.programs.bluetooth-manager-sidebar;
in
{
  options.programs.bluetooth-manager-sidebar = {
    enable = lib.mkEnableOption "bluetooth-manager-sidebar";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.bluetooth-manager-sidebar;
      defaultText = lib.literalExpression "pkgs.bluetooth-manager-sidebar";
      description = "The bluetooth-manager-sidebar package to use.";
    };

    extraCss = lib.mkOption {
      type = lib.types.lines;
      default = "";
      example = ''
        window {
          background-color: rgba(0, 0, 0, 0.85);
        }
      '';
      description = ''
        Custom CSS appended to `bm-sidebar.css`. The app reads it from
        `$XDG_CONFIG_HOME/bm-sidebar/bm-sidebar.css`.
        Run `bm-sidebar --reload-css` to apply changes to a running instance.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."bm-sidebar/bm-sidebar.css" = lib.mkIf (cfg.extraCss != "") {
      text = cfg.extraCss;
    };
  };
}
