{config, ...}:{
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
  services.darkman.scripts.anyrun = ''
    pkill -9 anyrun || exit 0
  '';
}
