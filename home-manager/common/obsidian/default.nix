{ inputs, pkgs, ... }: {
  nixpkgs.overlays = [
    inputs.obsidian-extensions.overlays.default
  ];

  programs.obsidian = {
    enable = true;
  };
}
