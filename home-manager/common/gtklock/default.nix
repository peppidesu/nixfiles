{inputs, pkgs, ...}: {
  imports = [
    inputs.self.homeManagerModules.gtklock
  ];

  programs.gtklock = {
    enable = true;
    modules = with pkgs; [
      gtklock-playerctl-module
      gtklock-powerbar-module
      gtklock-userinfo-module
    ];
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof gtklock || gtklock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 150;
          on-timeout = "brightnessctl -s set 10";
          on-resume = "brightnessctl -r";
        }
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
