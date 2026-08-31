{ pkgs, ... }:
{
  programs.waybar = {
    enable = true;

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
        modules-center = [ "custom/waymedia" ];
        modules-right = [
          "hyprland/submap"
          "custom/updates"
          "custom/bluetooth"
          "network"
          "pulseaudio"
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

        mpd = {
          format = "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}% ";
          format-disconnected = "Disconnected ";
          format-stopped = "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ";
          unknown-tag = "N/A";
          interval = 2;
          consume-icons = { on = " "; };
          random-icons = {
            off = "<span color=\"#f53c3c\"></span> ";
            on = " ";
          };
          repeat-icons = { on = " "; };
          single-icons = { on = "1 "; };
          state-icons = {
            paused = "";
            playing = "";
          };
          tooltip-format = "MPD (connected)";
          tooltip-format-disconnected = "MPD (disconnected)";
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

        pulseaudio = {
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
          on-click = "pavucontrol";
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
          on-click = "${pkgs.b}";
        };

        "hyprland/workspaces" = {
          format = "{id}";
          on-click = "activate";
          sort-by = "id";
        };

        "custom/waymedia" = {
          format = "{}";
          exec = "$HOME/.config/waybar/scripts/waymedia/waymedia";
          interval = 1;
          limit = 60;
          on-click = "playerctl play-pause";
          on-scroll-up = "playerctl next";
          on-scroll-down = "playerctl previous";
          pause-icon = "   ";
          play-icon = "   ";
          divider = " - ";
        };
      };
    };
  };
}
