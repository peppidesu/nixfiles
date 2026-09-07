{inputs, ...}: {
  imports = [
    inputs.self.homeManagerModules.bluetooth-manager-sidebar
  ];
  programs.bluetooth-manager-sidebar = {
    enable = true;
    extraCss = ''
      .bm-sidebar-window,
      .bm-sidebar-surface {
        background-color: rgba(39, 46, 51, 0.3);
      }
      .bm-sidebar-panel {
        margin: 16px;
      }
    '';
  };
}
