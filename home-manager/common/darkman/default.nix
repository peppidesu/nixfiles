{ config, ... }: {
  services.darkman = {
    enable = true;
    settings = {
      lat = 51.8;
      lng = 4.6;
      usegeoclue = false;
      dbusserver = true;
      portal = true;
    };
  };

  xdg.portal.config.common."org.freedesktop.impl.portal.Settings" = [ "darkman" ];
}
