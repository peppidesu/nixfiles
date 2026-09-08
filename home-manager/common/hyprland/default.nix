{lib, pkgs, inputs, osConfig,... }:{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd = {
      enable = true;
      enableXdgAutostart = true;
      variables = ["--all"];
    };
    plugins = [
      pkgs.hyprlandPlugins.hyprcapture
    ];
    configType = "lua";
    extraConfig = lib.mkMerge [
      (builtins.readFile ./hyprland.lua)
      (builtins.readFile ./hw-${osConfig.networking.hostName}.lua)
    ];
    # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };
}
