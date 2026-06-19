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

    mods = let
      modList = {
        "aai-loaders_0.2.11" = "sha256-Q1qHc5cNelIJ46Njzu0kJfquG/AZNDrQ4tiG0xZ7VGM=";
        "aai-signal-transmission_0.5.3" = "sha256-OMJyM6JvuSLX6NxOPqubOutzP8+Leu2TBZeTe0dL8b8=";
        "better-victory-screen_1.0.0" = "sha256-ALiNeh0o7UQMPYbn7/0pDpZ5RO5OUzPUgPeiQMNPKJU=";
        "blueprint-sandboxes_3.2.2" = "sha256-mdJrxsVyMw9YNmgqpK/07W/xi5/vXyo6Vboj7IyWWog=";
        "DiscoScience_2.0.1" = "sha256-kyQ7R97w/6ZBX38PMKg4PkMZlVCfqLOvyJOxaSYz1VE=";
        "even-distribution_2.0.2" = "sha256-1khtQe9/tHWnVpUFavLyucGUAkf+BGO7jR9guJhilFo=";
        "factoryplanner_2.0.50" = "sha256-0bZW19uF1KMXBkqNWVmpzfbcMbT5nPmHbNy8/H1a3fY=";
        "flib_0.16.5" = "sha256-Bs2jdo7kBbwwc9M2WzQAbUo5/3tGij+BzPET6JZHOWU=";
        "Flow Control_3.2.3" = "sha256-dxke0oj0qRo5vKsTJq6KiLWbX7v+h8cFVnRh+wzPCX4=";
        "Honk_5.1.1" = "sha256-E/h0Zy64lj+yjSRpK42LIyrjihXw+jSJFoSEqgqi7EE=";
        "krastorio2-assets-ultracube_2.0.0" = "sha256-sBEiv0zQEt+vux9hLk6lABqj70/ZcMkbieHE3F0eP1k=";
        "Milestones_1.4.7" = "sha256-Bz7kRvvBN+DKfPt6wPHTpmbWFPcBSKJDRVucMoz8HHU=";
        "nixie-tubes_2.0.9" = "sha256-0b5/ev4612nqCjaOZ8cal1I58G0TJUjFgr0oVUxXXO4=";
        "pushbutton_2.0.5" = "sha256-GbrerjeplPGz8voh9evL/swOr2u9nwQeB1Mo0jrsbcc=";
        "squeak-through-2_0.1.5" = "sha256-3TskFtVeuWHg1CrfJMgB8ZGoZtQnmZkhfYJ0ljPT0Fs=";
        "textplates_0.7.2" = "sha256-+k4jg0StO5xICweOSteUlXSzdlde/CHA3nt4ni0H+hI=";
        "Ultracube_0.7.0" = "sha256-CHHvZj8wuSmlO5ZLNg1EVF+uQTcb3yw8+wQc3VP+evY=";
      };
      modToDrv = modFileName: hash:
        pkgs.runCommand "copy-factorio-mod-${modFileName}" { } ''
          mkdir $out
          ln -s '${
            fetchTree {
              type = "file";
              url = "https://git.geenit.nl/noa/factorio-modlists/raw/branch/main/${lib.strings.escapeURL modFileName}.zip";
              narHash = hash;
            }
          }' $out/'${modFileName}.zip'
        ''
        // {
          deps = [ ];
        };
    in
      lib.mapAttrsToList modToDrv modList;

    game-name = "kuub";
    allowedPlayers = [
      "peppidesu"
      "itepastra"
    ];
    lan = true;
    nonBlockingSaving = true;
  };
}
