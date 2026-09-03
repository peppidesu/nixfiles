{ pkgs, lib, ... }:
let
  inherit (pkgs.lib) concatStringsSep mapAttrsToList;

  mkVars = vars: concatStringsSep "\n"
    (mapAttrsToList (name: value: "\$${name}: ${value};") vars);

  mkScss = {
    src,
    vars ? {},
    varsDark ? {},
  }:
    let
      combinedScss = pkgs.writeText "combined.scss" ''
        ${mkVars vars}
        @media (prefers-color-scheme: dark) {
          ${mkVars varsDark}
        }
        ${builtins.readFile src}
      '';
      pkg = pkgs.runCommand "compiled-css" {
        nativeBuildInputs = [ pkgs.dart-sass ];
      } ''
        mkdir $out
        sass --style=compressed --no-source-map ${combinedScss} $out/style.css
      '';
    in
      builtins.readFile (pkg + "/style.css");
in {
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = mkScss {
      src = ./style.scss;
      vars = {
        color-fg = "#5c6a72";
        color-grey0 = "#a6b0a0";
        color-bg0 = "#fffbef";
        color-bg2 = "#f8f5e4";

        color-red = "#f85552";
        color-yellow = "#dfa000";
        color-green = "#8da101";
        color-blue = "#3a94c5";
        color-purple = "#df69ba";

        color-orange = "#f57d26";

        color-bg-red = "#ffe7de";
        color-bg-yellow = "#fef2d5";
        color-bg-green = "#f3f5d9";
        color-bg-blue = "#ecf5ed";
        color-bg-purple = "#fceced";
      };
      varsDark = {
        color-fg = "#d3c6aa";
        color-grey0 = "#7a8478";
        color-bg0 = "#272e33";
        color-bg2 = "#374145";

        color-red = "#e67e80";
        color-yellow = "#dbbc7f";
        color-green = "#a7c080";
        color-blue = "#7fbbb3";
        color-purple = "#d699b6";

        color-orange = "#e69875";

        color-bg-red = "#493b40";
        color-bg-yellow = "#45443c";
        color-bg-green = "#3c4841";
        color-bg-blue = "#384b55";
        color-bg-purple = "#463f48";
      };
    };
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;
        spacing = 0;
        margin-top = 0;
        margin-left = 0;
        margin-right = 0;

        modules-left = [
          "custom/spacer"
          "hyprland/workspaces"
          "tray"
          "hyprland/window"
        ];
        modules-center = [ "custom/spotify" ];
        modules-right = [
          "hyprland/submap"
          "custom/spacer"
          "custom/updates"
          "custom/bluetooth"
          "network"
          "wireplumber"
          "cpu"
          "memory"
          "temperature"
          "clock"
          "battery"
          "custom/spacer"
        ];

        keyboard-state = {
          numlock = true;
          capslock = true;
          format = "{name} {icon}";
          format-icons = {
            locked = "";
            unlocked = "";
          };
        };

        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };

        tray = { spacing = 10; };

        clock = {
          tooltip-format = "<span>{calendar}</span>";
          interval = 1;
          format = "{:%H:%M:%S}";
          format-alt = "{:%Y-%m-%d %H:%M:%S}";
          calendar = {
            weeks-pos = "left";
            format = {
              today = "<span color='#FABD2F'><u>{}</u></span>";
              weeks = "<span color='#FABD2F'>{}</span>";
            };
          };
        };

        cpu = {
          format = " {usage}%";
          tooltip = false;
        };

        memory = {
          format = "  {}%";
          tooltip = false;
        };

        temperature = {
          thermal-zone = 2;
          hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
          critical-threshold = 80;
          format = "{icon} {temperatureC}°C";
          format-icons = [ "" "" "" ];
        };

        backlight = {
          format = "{percent}% {icon}";
          format-icons = [ "" "" "" "" "" "" "" "" "" ];
          reverse-scrolling = true;
        };

        battery = {
          states = {
            full = 100;
            good = 99;
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% {icon}";
          format-plugged = "{capacity}% {icon}";
          format-alt = "{time} {icon}";
          interval = 1;
          format-icons = [ "󰂎" "󰁻" "󰁾" "󰂀" "󰁹" ];
        };

        "hyprland/window" = {
          max-length = 50;
          seperate-outputs = true;
          icon = true;
        };

        "hyprland/submap" = {
          format = "{}";
          tooltip = true;
        };

        network = {
          format-wifi = "󰖩";
          format-ethernet = "󰲝";
          tooltip-format = "ssid : {essid}\naddr : {ipaddr}/{cidr}\ngate : {gwaddr}\ndev  : {ifname}";
          format-linked = "󰲝";
          format-disconnected = "";
          format-alt = "{ipaddr}/{cidr}";
        };

        wireplumber = {
          format = "{icon} {volume}% {format_source}";
          format-bluetooth = "󰂯 {icon} {volume}% {format_source}";
          format-bluetooth-muted = "󰂯 󰝟 {format_source}";
          format-muted = "󰝟 {format_source}";
          format-source = "󰍬";
          format-source-muted = "󰍭";
          format-icons = {
            headphone = "󰋋";
            hands-free = "󰋎";
            headset = "󰋎";
            phone = "";
            portable = "";
            car = "󰄋";
            default = [ "󰕾" "󰕾" "󰕾" ];
          };
          on-click = lib.getExe pkgs.pwvucontrol;
          reverse-scrolling = true;
        };

        "custom/vpn" = {
          format = "VPN ";
          exec = "echo '{\"class\": \"connected\"}'";
          exec-if = "test -d /proc/sys/net/ipv4/conf/tun0";
          return-type = "json";
          interval = 5;
        };

        "custom/bluetooth" = {
          format = "";
          on-click = lib.getExe pkgs.bluetooth-manager-sidebar;
        };

        "hyprland/workspaces" = {
          format = "{id}";
          on-click = "activate";
          sort-by = "id";
        };

        "custom/spotify" = {
          exec = ''${lib.getExe pkgs.playerctl} metadata --player=spotify -F -f "{{ status }}: {{ artist }} - {{ title }}"'';
          format = "{}";
          on-click = "${lib.getExe pkgs.playerctl} --player=spotify play-pause";
          on-click-middle = lib.getExe pkgs.spotify;
          on-scroll-up = "${lib.getExe pkgs.playerctl} --player=spotify volume 0.01+";
          on-scroll-down = "${lib.getExe pkgs.playerctl} --player=spotify volume 0.01-";
        };
      };
    };
  };
}
