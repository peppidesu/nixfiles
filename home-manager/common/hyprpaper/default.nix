{...}:let
path-light = ./mononoke.png;
  path-dark = ./mononoke-dark.png;
in
{
  services.darkman.scripts.hyprpaper =        ''
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
    enable=true;
    settings={
      splash=false;
      preload = [path-light path-dark];
      wallpaper = {
        monitor="";
        path = "${path-dark}";
      };
    };
  };
}
