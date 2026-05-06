{pkgs, ...}: {
  custom.caddy.publicServices.radicale.proxy = "http://localhost:5232";

  services.radicale = {
    enable = true;
    settings = {
      server.hosts = [ "0.0.0.0:5232" ];
      auth = {
        type = "htpasswd";
        htpasswd_filename = builtins.toString (pkgs.writeText "radicale_htpasswd" ''peppidesu:$2a$12$00CEcwqMNNRHXXu9toCsK.sfmb6VQJMvkwZfp53F/H6yRGNZjytKm'');
        htpasswd_encryption = "bcrypt";
      };
    };
  };
}
