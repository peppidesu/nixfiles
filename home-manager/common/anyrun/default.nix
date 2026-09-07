{config, lib, pkgs, ...}:{
  programs.anyrun = {
    enable = true;
    extraCss = builtins.readFile ./style.css;
    config = {
      closeOnClick = true;
      height.absolute = 500;
      x.fraction = 0.5;
      y.fraction = 0.5;
      hideIcons = false;
      hidePluginInfo = true;
      ignoreExclusiveZones = false;
      layer = "overlay";
      maxEntries = 10;
      plugins = builtins.map (plugin: "${config.programs.anyrun.package}/lib/${plugin}") [
        "libapplications.so"
        "libsymbols.so"
        "libshell.so"
        "libtranslate.so"
        "librink.so"
        "libwebsearch.so"
      ];
    };
  };
  systemd.user.services.anyrund = {
    Unit = {
      PartOf = [ "graphical-session.target" ];
      BindsTo = [ "graphical-session.target" ];
      Description = "anyrun daemon";
    };

    Service = {
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.anyrun} daemon";
      Restart = "on-failure";
      TimeoutStopSec = 15;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
  services.darkman.scripts.anyrun = ''
    systemctl --user restart anyrund.service
  '';
}
