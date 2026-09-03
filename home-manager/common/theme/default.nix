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
  ];

  services.darkman.scripts.gtk = let
    makegtk3pkg = { name, isDark, ... }:
      (pkgs.formats.ini { }).generate "settings.ini" {
        Settings = lib.attrsets.mapAttrs' (n: v: { name = "gtk-${n}"; value = v; }) {
          theme-name = name;
          icon-theme-name = "Papirus-Dark";
          font-name = "Adwaita Sans 11";
          cursor-theme-name = "Adwaita";
          cursor-theme-size = 24;
          toolbar-style = "GTK_TOOLBAR_ICONS";
          toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";
          button-images = 0;
          menu-images = 0;
          enable-event-sounds = 1;
          enable-input-feedback-sounds = 0;
          xft-antialias = 1;
          xft-hinting = 1;
          xft-hintstyle = "hintslight";
          xft-rgba = "rgb";
          application-prefer-dark-theme = if isDark then 1 else 0;
        };
      };
    makegtk4pkg = { name, isDark, ... }:
      (pkgs.formats.ini { }).generate "settings.ini" {
        Settings = lib.attrsets.mapAttrs' (n: v: { name = "gtk-${n}"; value = v; }) {
          theme-name = name;
          icon-theme-name = "Papirus-Dark";
          font-name = "Adwaita Sans 11";
          cursor-theme-name = "Adwaita";
          cursor-theme-size = 24;
          application-prefer-dark-theme = if isDark then 1 else 0;
        };
      };
    gsettings = lib.getExe' pkgs.glib.bin "gsettings";
  in ''
    export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:''${XDG_DATA_DIRS:-/run/current-system/sw/share}"

    env | grep -E '^(DBUS|XDG|GSETTINGS|GTK)' >&2
      ${lib.getExe' pkgs.glib "gsettings"} get \
        org.gnome.desktop.interface gtk-theme >&2

    case "$1" in
    dark)
      ln -sf ${makegtk3pkg { name = darkTheme.gtk.name; isDark = true; }} $HOME/.config/gtk-3.0/settings.ini
      ln -sf ${makegtk4pkg { name = darkTheme.gtk.name; isDark = true; }} $HOME/.config/gtk-4.0/settings.ini

      ${gsettings} set org.gnome.desktop.interface color-scheme 'prefer-dark'
      ${gsettings} set org.gnome.desktop.interface gtk-theme '${darkTheme.gtk.name}'
      ${gsettings} set org.gnome.desktop.interface icon-theme '${darkTheme.icon.name}'
      ;;
    light)
      ln -sf ${makegtk3pkg { name = lightTheme.gtk.name; isDark = false; }} $HOME/.config/gtk-3.0/settings.ini
      ln -sf ${makegtk4pkg { name = lightTheme.gtk.name; isDark = false; }} $HOME/.config/gtk-4.0/settings.ini

      ${gsettings} set org.gnome.desktop.interface color-scheme 'prefer-light'
      ${gsettings} set org.gnome.desktop.interface gtk-theme '${lightTheme.gtk.name}'
      ${gsettings} set org.gnome.desktop.interface icon-theme '${lightTheme.icon.name}'
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
