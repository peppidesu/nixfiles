{...}:{
  services.darkman ={enable = true;
    settings = {lat = 51.8; lng=4.6; usegeoclue=false; dbusserver = true; portal=true;};
    scripts = {
      gtk = ''
      export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"

      case "$1" in
      dark)
        gsettings set org.gnome.desktop.interface gtk-theme 'Everforest-Red-Dark-Compact'
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
        ;;
      light)
        gsettings set org.gnome.desktop.interface gtk-theme 'Everforest-Red-Light-Compact'
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
        gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Light'
        ;;
      esac
      '';
      anyrun = ''
        pkill -9 anyrun || exit 0
      '';
    };
  };
}
