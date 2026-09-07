{ lib, pkgs, config, ... }:

let
  nwgHelloHypr = pkgs.writeText "nwg-hello-hyprland.lua" ''
    hl.monitor({
        output   = "",
        mode     = "preferred",
        position = "auto",
        scale    = 1,
    })
    hl.config({
        misc = {
            disable_hyprland_logo = true,
        },
        animations = {
            enabled = false,
        },
    })
    hl.on("hyprland.start", function()
        hl.exec_cmd("nwg-hello; hyprctl dispatch 'hl.dsp.exit()'")
    end)
  '';
in {
  options.peppidesu.greeter = let
    inherit (lib.options) mkEnableOption;
  in {
    enable = mkEnableOption "Enable greeter";
  };
  config = lib.mkIf config.peppidesu.greeter.enable {
    environment.systemPackages = with pkgs; [
      nwg-hello
      hyprland
    ];

    environment.pathsToLink = [ "/share/wayland-sessions" "/share/xsessions" ];

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.hyprland}/bin/start-hyprland -- --config ${nwgHelloHypr}";
          user = "greeter";
        };
      };
    };
  };
}
