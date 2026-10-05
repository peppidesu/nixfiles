{ lib, config, pkgs, ... }: {
  options =
    let
      inherit (lib.options) mkEnableOption;
    in
    {
      profiles.graphical = {
        enable = mkEnableOption "Basic applications for graphical shell";
        games = mkEnableOption "Games and such";
      };
    };

  config = lib.mkMerge [
    (lib.mkIf config.profiles.graphical.enable {
      hardware.graphics.enable = true;
      hardware.graphics.enable32Bit = true;
      services.gvfs.enable = true;
    })
    (lib.mkIf config.profiles.graphical.games {
      programs.steam = {
        enable = true; # Master switch, already covered in installation
        remotePlay.openFirewall = true;  # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server hosting
        # Other general flags if available can be set here.
      };
      programs.gamemode.enable = true;
      programs.gamescope = {
        enable = true;
        enableWsi = true;
        capSysNice = false;
      };
      programs.steam.extraCompatPackages = [
        pkgs.proton-ge-bin
      ];
    })
  ];
}
