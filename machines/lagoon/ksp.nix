{pkgs, lib, config, ...}: {
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      autoPrune.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    arion = {
      backend = "podman";
      projects = {
        "ksp-luna".settings.services."luna".service = {
          image = "ghcr.io/lunamultiplayer/lunamultiplayer/server:master";
          restart = "unless-stopped";
          environment = { TZ="Europe/Amsterdam"; };
          ports = [
            "8800:8800/udp"
            "8900:8900"
          ];
          volumes = [
            {
              type = "bind";
              source = "/opt/ksp-luna/config";
              target = "/LMPServer/Config";
            }
            {
              type = "bind";
              source = "/opt/ksp-luna/universe";
              target = "/LMPServer/Universe";
            }
            {
              type = "bind";
              source = "/opt/ksp-luna/plugins";
              target = "/LMPServer/Plugins";
            }
            {
              type = "bind";
              source = "/opt/ksp-luna/logs";
              target = "/LMPServer/Logs";
            }
          ];
        };
      };
    };
  };
  systemd.tmpfiles.rules = [
    "d /opt/ksp-luna/config 1770 kspluna kspluna -"
    "d /opt/ksp-luna/universe 1770 kspluna kspluna -"
    "d /opt/ksp-luna/plugins 1770 kspluna kspluna -"
    "d /opt/ksp-luna/logs 1660 kspluna kspluna -"
  ];
  users.users.peppidesu.extraGroups = ["podman"];


}
