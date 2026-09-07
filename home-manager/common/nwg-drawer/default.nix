{pkgs, inputs, ...}: {
  imports = [
    inputs.self.homeManagerModules.nwg-drawer
  ];

  programs.nwg-drawer = {
    enable = true;
    settings = {
      terminal = "kitty";
      file-manager = "nautilus";
      columns = 6;
      icon-size = 48;
      spacing = 24;
    };
    style = ''
        window {
          background-color: rgba(39, 46, 51, 0.9);
        }
        #category-button {
          margin-left: 4px;
          margin-right: 4px;
          padding: 5px 10px;
        }
        #category-button.selected {
          background-color: #493b40;
          color: #e67e80;
        }
    '';
  };
}
