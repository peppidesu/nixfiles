{inputs, ...}: {
  imports = [
    inputs.self.homeManagerModules.bluetooth-manager-sidebar
  ];
  programs.bluetooth-manager-sidebar = {
    enable = true;
    extraCss = ''
      .bm-sidebar-window,
      .bm-sidebar-surface {
        background-color: alpha(@window_bg_color, 0.25);
      }
      .bm-sidebar-panel {
        margin: 16px;
        border-color: @accent_fg_color;
      }
    '';
  };
}
