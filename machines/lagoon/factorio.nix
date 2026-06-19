{lib, pkgs, ...}: {

  services.factorio = {

    enable = true;
    openFirewall = true;
    package = (pkgs.factorio-headless.overrideAttrs (oldAttrs: {
          installPhase = (oldAttrs.installPhase or "") + ''
            rm -rf "$out/share/factorio/data/space-age"
            rm -rf "$out/share/factorio/data/quality"
          '';
    }));

    mods =
      let
        modList = {
          "aai-loaders_0.2.11" = "";
          "aai-signal-transmission_0.5.3" = "";
          "better-victory-screen_1.0.0" = "";
          "blueprint-sandboxes_3.2.2" = "";
          "DiscoScience_2.0.1" = "";
          "even-distribution_2.0.2"= "";
          "factoryplanner_2.0.50"= "";
          "flib_0.16.5"= "";
          "Flow Control_3.2.3"= "";
          "Honk_5.1.1"= "";
          "krastorio2-assets-ultracube_2.0.0"= "";
          "Milestones_1.4.7"= "";
          "nixie-tubes_2.0.9"= "";
          "pushbutton_2.0.5"= "";
          "squeak-through-2_0.1.5"= "";
          "textplates_0.7.2"= "";
          "Ultracube_0.7.0"= "";
        };
        modToDrv = modFileName: hash:
        pkgs.runCommand "copy-factorio-mod-${modFileName}" {} ''
            mkdir $out
            ln -s '${
            fetchTree {
              type="file";
              url = "https://git.geenit.nl/noa/factorio-modlists/raw/branch/main/${modFileName}.zip";
              narHash = hash;
            }}' $out/'${modFileName}.zip'

        '';
      in
        builtins.mapAttrsToList modToDrv modList;

    game-name = "kuub";
    allowedPlayers = [
      "peppidesu"
      "itepastra"
    ];
    lan = true;
    nonBlockingSaving = true;
  };
}
