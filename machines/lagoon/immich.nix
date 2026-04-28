{config, ...}: {
  services.immich = {
    enable = true;
    port = 2283;
  };
  custom.caddy.publicServices = {
    "immich".proxy = "http://localhost:${builtins.toString config.services.immich.port}";
  };
}
