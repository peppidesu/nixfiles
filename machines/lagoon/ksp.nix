{pkgs, lib, config, ...}: {
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      autoPrune.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    arion = {
      backend = "podman-socket";
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
    "d /opt/ksp-luna/config 1775 12001 12001 -"
    "d /opt/ksp-luna/universe 1775 12001 12001 -"
    "d /opt/ksp-luna/plugins 1775 12001 12001 -"
    "d /opt/ksp-luna/logs 1775 12001 12001 -"
  ];

  users.users.peppidesu.extraGroups = ["podman"];
  networking.firewall = {
    allowedTCPPorts = [ 8900 ];
    allowedUDPPorts = [ 8800 ];
  };


}
