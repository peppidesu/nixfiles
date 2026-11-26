{ inputs, ... }: {
  imports = [
    inputs.self.nixosModules.minecraft
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  services.mc-modded = {
    enable = true;
    name = "septabee";
    minecraftVersion = "26.3";
    port = 25565;
    openFirewall = true;

    mods = [
      {
        project = "9eGKb6K1";       # e.g. fabric-api -> P7dR8mSH
        version = "x9jLR94Q";
        file    = "voicechat-fabric-2.6.27+26.3.jar";
        hash    = "sha512-8t5mdhwPJJuw+aSzSPmLl6tOidPtP9N2OEIDZLdDG3V5M6oIwMw+e6PdhaYC1sLeMTwjCfxYfpPKvzH8X23yfg==";
      }
      {
        project = "TjSm1wrD";
        version = "pa9cAfYg";
        file    = "modernfix-5.27.20-build.2.jar";
        hash    = "sha512-tYZDQFYQeqxO+G6TUdZhcNrGWkWh5fi9SPuTGzASqyQxsWR265wlZ3MznitMYPbz6QpHCRgPcAsq6ln/YH9CQw==";
      }
      {
        project = "lKiXKLvv";
        version = "rcaiziaw";
        file    = "lod-server-support-fabric-0.23.0+26.3.jar";
        hash    = "sha512-6i5+lsziEjfg6585D04cdKzrwt/YXgNbZ7tHcuouNBIxHgQ3DwQYJugxcKvihZCGLYSCoaIn24K5Pw4rBOXWAg==";
      }
      {
        project = "uXXizFIs";
        version = "d5ddUdiB";
        file    = "ferritecore-9.0.0-fabric.jar";
        hash    = "sha512-2B+pfhF4TBnUL4nC9DODHQB2A91xk87kX6F35KapxSs4SxmFhuBKD39jzZlv7XEzIleL3pqNtX4RiIVK5cvlhA==";
      }
      {
        project = "fALzjamp";
        version = "86FKD9qx";
        file    = "Chunky-Fabric-1.5.66.jar";
        hash    = "sha512-bwMj2qadYb07P76di3E2ZNm3xpGCGD+Nz/Y2K0N4Njl3ipbjIhXb/TKViPBrYKXZNlbbsdORxmDbIDSCqpctXg==";
      }
      {
        project = "P7dR8mSH";
        version = "Zns5SSRA";
        file    = "fabric-api-0.166.2+26.3.jar";
        hash    = "sha512-+2hqn6kjJIMoEHoSSYIp1pUeMWJX8Yt9Dky9aIW6RH7VCkQHaopbpHz+IEOzKds1h6sACuqx+s4mslh6XUumtQ==";
      }

      # ... more mods
    ];

    operators = {
      peppidesu = {
        uuid = "9cf4b1f7-9215-4d63-bf64-2f375d867201";
        level = 4;
        bypassesPlayerLimit = true;
      };
      itepastra = {
        uuid = "4a380e46-e249-4bb9-80a7-f3101679361a";
        level = 4;
        bypassesPlayerLimit = true;
      };
    };

    serverProperties = {
      motd = "yuri yuri yuri yuri yuri yuri yuri yuri";
      max-players = 100;
      white-list = false;
      difficulty = "hard";

    };
  };
}
