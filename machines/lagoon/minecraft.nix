{ ... }: {
  services.minecraft-server = {
    enable = true;
    eula = true;
    openFirewall = true;
    declarative = true;
    serverProperties = {
      server-port = 25565;
      white-list = false;
      motd = "jawohl";
      enable-rcon = false;
      difficulty = 3;
    };
  };
}
