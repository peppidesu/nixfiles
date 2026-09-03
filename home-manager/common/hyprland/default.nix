{lib, osConfig,... }:{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd = {
      enable = true;
      enableXdgAutostart = true;
      variables = ["--all"];
    };
    plugins = [];
    configType = "lua";
    extraConfig = lib.mkMerge [
      (builtins.readFile ./hyprland.lua)
      (builtins.readFile ./hw-${osConfig.networking.hostName}.lua)
    ];
  };
}
