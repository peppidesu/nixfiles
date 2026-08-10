{config, inputs, pkgs, ...}: {
  services.flurry = {
    enable = true;
    package = inputs.flurry.packages.${pkgs.stdenv.hostPlatform.system}.default;
    host = "0.0.0.0";
    web_host = "0.0.0.0:44902";
    openFirewall = true;
    grid_width = 1920;
    grid_height = 1080;
  };
  custom.caddy.publicServices = {
    "flurry".proxy = "http://${config.services.flurry.web_host}";
  };
}
