{inputs, lib, config, ...}: {
  imports = [
    inputs.nixvim.nixosModules.nixvim
  ];

  options = let
    inherit (lib.options) mkEnableOption;
  in {
    custom.neovim.enable = mkEnableOption "Enable neovim config";
    custom.neovim.lsps = mkEnableOption "Enable LSPs";
  };

  config = let
    cfg = config.custom.neovim;
  in lib.mkIf (cfg.enable) {
    programs.nixvim = {
      enable = true;
      colorschemes.ayu.enable = true;
      clipboard.register = "unnamedplus";

    };
  };
}
