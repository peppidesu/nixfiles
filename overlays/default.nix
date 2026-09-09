# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    nwg-drawer = (prev.nwg-drawer.override {
      # use clang instead of gcc (build performance)
      buildGoModule = prev.buildGoModule.override {
        stdenv = prev.clangStdenv;
      };
    }).overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ [
        ./patches/nwg-drawer-valign.patch
      ];
    });

    everforest-gtk-theme = final.lib.makeOverridable (
        { themes ? []
        , colors ? []
        , size ? "standard"
        }:

        prev.everforest-gtk-theme.overrideAttrs (_oldAttrs: {
          installPhase = ''
            runHook preInstall

            mkdir -p "$out/share/"{themes,icons}

            cp -a icons/* "$out/share/icons/"

            for iconTheme in "$out/share/icons/"*; do
              gtk-update-icon-cache "$iconTheme"
            done

            cd themes
            ./install.sh --name Everforest \
              ${if themes != [] then "--theme ${final.lib.escapeShellArgs themes}" else ""} \
              ${if colors != [] then "--color ${final.lib.escapeShellArgs colors}" else ""} \
              --size ${final.lib.escapeShellArg size} \
              --dest "$out/share/themes"
            cd ..

            runHook postInstall
          '';
        })
      ) { };
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  # unstable-packages = final: _prev: {
  #   unstable = import inputs.nixpkgs-unstable {
  #     system = final.system;
  #     config.allowUnfree = true;
  #   };
  # };
}
