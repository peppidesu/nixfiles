{
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:
{
  imports = [
    ./console
  ]
  ++ lib.optionals osConfig.profiles.graphical.enable [
    ./theme
    ./hyprland
    ./hyprpaper
    ./darkman
    ./anyrun
    ./dunst
    ./kitty
    ./waybar
    ./zed
    ./chromium
    ./nwg-drawer
    ./bluetooth-manager-sidebar
    ./gtklock
    # ./common/swaync
  ];
  home.packages = lib.optionals osConfig.profiles.graphical.enable [
    pkgs.nautilus
    pkgs.nautilus-open-any-terminal
    pkgs.sushi
    pkgs.gnome-disk-utility
    pkgs.seahorse
    pkgs.gnome-calendar
    pkgs.wl-clipboard
    pkgs.swappy
  ];


  services.gnome-keyring.enable = true;

  # xdg desktop portal
  xdg.portal = {
    enable = osConfig.profiles.graphical.enable;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    xdgOpenUsePortal = true;
  };
}
