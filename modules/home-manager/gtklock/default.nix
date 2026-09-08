{ config, lib, pkgs, ... }:

let
  cfg = config.programs.gtklock;

  settingsFormat = pkgs.formats.ini { };
in
{
  options.programs.gtklock = {
    enable = lib.mkEnableOption "gtklock, a GTK-based lockscreen for Wayland";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.gtklock;
      defaultText = "pkgs.gtklock";
      description = "The gtklock package to use.";
    };

    modules = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      example = lib.literalExpression ''
        with pkgs; [
          gtklock-playerctl-module
          gtklock-powerbar-module
          gtklock-userinfo-module
        ]
      '';
      description = ''
        gtklock modules to make available. The module wrapper is updated so the
        modules can be discovered at runtime.
      '';
    };

    config = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      example = lib.literalExpression ''
        {
          main = {
            "disable-input-inhibit" = false;
            "idle-activate" = 30;
            "hidden-mode" = false;
          };
          clock = {
            "clock-format" = "%H:%M";
          };
        }
      '';
      description = ''
        gtklock configuration written to
        <filename>$XDG_CONFIG_HOME/gtklock/config.ini</filename>.
        See <link xlink:href="https://github.com/jovanlanik/gtklock"/> for
        available options.
      '';
    };

    style = lib.mkOption {
      type = lib.types.nullOr lib.types.lines;
      default = null;
      example = ''
        window {
          background: #000000;
        }
      '';
      description = ''
        gtklock CSS stylesheet written to
        <filename>$XDG_CONFIG_HOME/gtklock/style.css</filename>.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (cfg.package.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ cfg.modules;
        postInstall = (old.postInstall or "") + ''
          ${lib.optionalString (cfg.modules != []) ''
            wrapProgram $out/bin/gtklock \
              --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath cfg.modules}"
          ''}
        '';
      }))
    ] ++ cfg.modules;

    xdg.configFile."gtklock/config.ini" = lib.mkIf (cfg.config != { }) {
      source = settingsFormat.generate "gtklock-config.ini" cfg.config;
    };

    xdg.configFile."gtklock/style.css" = lib.mkIf (cfg.style != null) {
      text = cfg.style;
    };
  };
}
