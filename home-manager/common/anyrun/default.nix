{config, ...}:{
  programs.anyrun = {
    enable = true;
    config = {
      closeOnClick = true;
      height.absolute = 500;
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
}
