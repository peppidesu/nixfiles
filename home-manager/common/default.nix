{inputs, lib, osConfig, pkgs, ...}: {
  imports = [
    ./console
  ] ++ lib.optionals osConfig.profiles.graphical.enable [
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
  ];
}
