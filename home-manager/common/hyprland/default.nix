{lib, osConfig,... }:{
  wayland.windowManager.hyprland = {
    enable = true;
    plugins = [];
    extraConfig = lib.mkMerge [
      builtins.readFile "./hyprland.lua"
      builtins.readFile "hw-${osConfig.networking.hostname}.lua"
    ];
  };
}
