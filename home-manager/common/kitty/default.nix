{...}: {
  programs.kitty = {
    enable = true;
    autoThemeFiles = {
      dark = "everforest_dark_hard";
      light = "everforest_light_hard";
      noPreference = "everforest_dark_hard";
    };
    settings = {
      window_padding_width = 5;
      font_family = "family=\"Maple Mono NF\" features=\"calt cv01 ss01\"";
    };
  };
}
