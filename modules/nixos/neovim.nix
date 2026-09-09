{inputs, lib, config, ...}: {
  imports = [
    inputs.nixvim.nixosModules.nixvim
  ];

  options.peppidesu.neovim = let
    inherit (lib.options) mkEnableOption;
  in {
    enable = mkEnableOption "Enable neovim config";
    lsps = mkEnableOption "Enable LSPs";
  };

  config = let
    cfg = config.peppidesu.neovim;
  in lib.mkIf (cfg.enable) {
    programs.nixvim = {
      enable = true;
      nixpkgs.source = inputs.nixpkgs;
      colorschemes.ayu.enable = true;
      clipboard.register = "unnamedplus";
    };
  };
}
