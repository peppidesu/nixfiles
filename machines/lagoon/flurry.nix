{ inputs, pkgs, ... }:
{
  imports = [
    inputs.flurry.nixosModules.flurry
  ];

  services.flurry = {
    enable = true;
    package = inputs.flurry.packages.${pkgs.stdenv.hostPlatform.system}.default;
    host = "0.0.0.0";
    openFirewall = true;
    grid_width = 1280;
    grid_height = 1024;
  };

  custom.caddy = {
    publicServices = {
      "flurry".proxy = "http://localhost:3000";
    };
  };
}
