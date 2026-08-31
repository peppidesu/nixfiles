{osConfig, lib, pkgs,...}:{
  config = {
    services.dunst = {
      enable = true;
      iconTheme = {
        name = "Papirus";
        package = pkgs.papirus-icon-theme;
        size = "64x64";
      };
      settings = {
        global = rec {
          monitor = 0;
          follow = "none";
          width = 400;
          height = "(0, 128)";
          origin = "top-center";
          offset = "0x32";
          scale=0;
          notification_limit = 20;
          progress_bar=true;
          progress_bar_height = "(10, 10)";
          progress_bar_width = 1;
          progress_bar_min_width=150;
          progress_bar_max_width = 300;
          progress_bar_corner_radius= builtins.div progress_bar_height 2;
          progress_bar_corners="all";
          icon_corner_radius = 32;
          icon_corners = "all";
          indicate_hidden = true;
          transparency = 0;
          seperator_height=2;
          padding=16;
          horizontal_padding=16;
          text_icon_padding=0;
          frame_width=4;
          frame_color="#ee6183";
          gap_size=0;
          seperator_color="frame";
          sort="yes"; # this is not valid
          font="Maple Mono NF 10";
          line_height = 0;
          markup="full";
          format="<b>%s</b>\\n%b";
          alignment="left";
          vertical_alignment="center";
          show_age_threshold=60;
          ellipsize="middle";
          ignore_newline="no";
          stack_duplicates=true;
          hide_duplicate_count=false;
          show_indicators=true;
          enable_recursive_icon_lookup=true;

          sticky_history=true;
          history_length=20;
          browser = "${lib.getExe pkgs.xdg-open}";
          always_run_script=true;
          corner_radius=8;
          corners="all";
          ignore_dbusclose=false;
          mouse_left_click="close_current";
          mouse_middle_click="do_action, close_current";
          mouse_right_click="close_all";
        };

        experimental.per_monitor_dpi = true;

        urgency_low = {
          background = "#171f28";
          foreground = "#9bb0b5";
          timeout = 10;
        };

        urgency_normal = {
          background = "#171f28";
          foreground = "#c7d5d2";
          timeout = 10;
          override_pause_level = 30;
        };

        urgency_critical={
          background = "#d33678";
          foreground = "#ecedea";
          frame_color = "#ecedea";
          timeout = 0;
          override_pause_level = 60;
        };
      };
    };
  };
  osConfig.fonts.packages = [pkgs.maple-mono.NF];
}
