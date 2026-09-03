{lib, config, ...}: {
  options = let
    inherit (lib.options) mkEnableOption;
  in {
    profiles.graphical = {
      enable = mkEnableOption "Enable basic applications for graphical shell";
    };
  };

  config = {
    hardware.graphics.enable = config.profiles.graphical.enable;
    hardware.graphics.enable32Bit = config.profiles.graphical.enable;
  };
}
