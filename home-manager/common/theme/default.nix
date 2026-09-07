{lib, pkgs, config, ...}: let
  lightTheme = {
    gtk.name = "Everforest-Red-Light";
    gtk.package = pkgs.everforest-gtk-theme;

    icon.name = "Papirus-Light";
    icon.package = pkgs.papirus-icon-theme.override {
      color = "red";
    };
  };

  darkTheme = {
    gtk.name = "Everforest-Red-Dark";
    gtk.package = lightTheme.gtk.package;

    icon.name = "Papirus-Dark";
    icon.package = lightTheme.icon.package;
  };

in {
  home.packages = [
    lightTheme.gtk.package
    lightTheme.icon.package
    darkTheme.gtk.package
    darkTheme.icon.package
    pkgs.maple-mono.NF
    pkgs.maple-mono.NF-CN
  ];

  services.darkman.scripts.gtk = let
    dconf = lib.getExe pkgs.dconf;
  in ''
    export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:''${XDG_DATA_DIRS:-/run/current-system/sw/share}"

    case "$1" in
    dark)
      ${dconf} write /org/gnome/desktop/interface/color-scheme '"prefer-dark"'
      ${dconf} write /org/gnome/desktop/interface/gtk-theme '"${darkTheme.gtk.name}"'
      ${dconf} write /org/gnome/desktop/interface/icon-theme '"${darkTheme.icon.name}"'
      ;;
    light)

      ${dconf} write /org/gnome/desktop/interface/color-scheme '"prefer-light"'
      ${dconf} write /org/gnome/desktop/interface/gtk-theme '"${lightTheme.gtk.name}"'
      ${dconf} write /org/gnome/desktop/interface/icon-theme '"${lightTheme.icon.name}"'
      ;;
    esac
  '';

  xdg.configFile = {
    "gtk-4.0/gtk.css" = {
      force = true;
      text = ''
        @import url("${lightTheme.gtk.package}/share/themes/${lightTheme.gtk.name}/gtk-4.0/gtk.css");
        @media (prefers-color-scheme: dark) {
          @import url("${darkTheme.gtk.package}/share/themes/${darkTheme.gtk.name}/gtk-4.0/gtk.css");
        }
      '';
    };
  };
}
