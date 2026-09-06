{lib, config, ...}: {
  options = let
    inherit (lib.options) mkEnableOption;
  in {
    profiles.graphical = {
      enable = mkEnableOption "Enable basic applications for graphical shell";
    };
  };

  config = lib.mkIf config.profiles.graphical.enable {
    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;
  };
}
