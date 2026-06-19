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
        modDir = /opt/factorio-mods;
        modList = lib.pipe modDir [
          builtins.readDir
          (lib.filterAttrs (k: v: v == "regular"))
          (lib.mapAttrsToList (k: v: k))
          (builtins.filter (lib.hasSuffix ".zip"))
        ];
        validPath = modFileName:
          builtins.path {
            path = modDir + "/${modFileName}";
            name = lib.strings.sanitizeDerivationName modFileName;
          };
        modToDrv = modFileName:
          pkgs.runCommand "copy-factorio-mods" {} ''
            mkdir $out
            ln -s '${validPath modFileName}' $out/'${modFileName}'
          ''
          // { deps = []; };
      in
        builtins.map modToDrv modList;

    game-name = "kuub";
    allowedPlayers = [
      "peppidesu"
      "itepastra"
    ];
    lan = true;
    nonBlockingSaving = true;
  };
}
