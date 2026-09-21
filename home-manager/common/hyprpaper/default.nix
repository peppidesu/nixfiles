{ config, ... }:
let
  path-light = if config.home.username == "daklab" then ./dakota-light.jpg else ./flowers.png;
  path-dark = if config.home.username == "daklab" then ./dakota-dark.jpg else ./berries.png;
in
{
  config = {
    services.darkman.scripts.hyprpaper = ''
      case "$1" in
      dark)
        hyprctl hyprpaper wallpaper ",${path-dark}" || exit 0
        ;;
      light)
        hyprctl hyprpaper wallpaper ",${path-light}" || exit 0
        ;;
      esac
    '';

    services.hyprpaper = {
      enable = true;
      settings = {
        splash = false;
        preload = [
          "${path-light}"
          "${path-dark}"
        ];
        wallpaper = {
          monitor = "";
          path = "${path-dark}";
        };
      };
    };
  };
}
