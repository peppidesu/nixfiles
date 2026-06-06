# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
moduleArgs@{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # inputs.self.nixosModules.example
    inputs.self.nixosModules.neovim
    inputs.self.nixosModules.caddy

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    ./hardening.nix

    ./jellystack.nix
    ./ksp.nix
    ./immich.nix
    ./radicale.nix
    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];
  home-manager.users."peppidesu" = ../../home-manager/peppidesu.nix;
  home-manager.extraSpecialArgs = { inherit inputs; };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      inputs.self.overlays.additions
      inputs.self.overlays.modifications
      inputs.self.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      # flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  networking = {
    hostName = "lagoon";
    tempAddresses = "disabled";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
    };
    networkmanager.enable = true;
  };

  age.secrets.wg-key-lagoon = {
    file = "${inputs.self.outPath}/secrets/wg-key-lagoon.age";
    mode = "640";
  };
  networking.wg-quick.interfaces.wg0 = (import ../../common/wg.nix moduleArgs).peers.lagoon;

  programs.zsh.enable = true;
  users.users = {
    peppidesu = {
      # TODO: You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO97Yve7hz7krbWA2FOgEihMAoGNmb2PhiwrUB3vXPzS peppidesu@dreadnought"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA+DDOyMQZKiFMo2fPOAjmtPGZ2dnUAuonSGwqfxgG0Y peppidesu@catamaran"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDmUSRs2akTTWtiaCcB5PNaLFJlwZmvD8YEZp2R4SQ56gj1xddZ0QP8XQIqRd6cmkaGzS9QzNpo03mlaOUTItFarp+OJh7oe9DcqpLR7+30mdLJgmYC6SOm/Upm9jZbl+YVuRbCWUXJ8pgKeJ+GseiKUx/3nPFPJ17Z7xV1GwPBVDxE4F3TVF/JFn6NYE0NF0I35lYUT8JOrmr7r2+VYBt9Pbqta7G6afTl4ETX/pDDiEHQAsf5dUvF/FdAUp50DMVqC81xPlx/ajMzI4thssA8CkUDZdns7WhWSvDuyCz6bRZhnBqJ0oM9clhljhVq7eAScAEH4mM0XEexlE5NUmGqLZJT7NZIX+SRhxtKMTZBY3y6w6cxgNMo8lAhp0d1mlSmBEB1cvlCr38ZtcAyYA1m3vHwnJ4vsbCxxGZeTyLY+mZC4dFcSSyc+P3DtxBle7q6F/Qc9K53I454YsUVHTzD/K1A6r75/6igQBKEoGScVQX5qFLFWOu0k1hOEV3mT3jzP48l5iEz6whdO0EKbHJT3vvM+vj3zLzJ9YeSTDbxTE0AhMNt17yICB/vX1Fi/SwlwjYgUQnwiKbqkOaT5ZTxcqcv3x0EyTdq43J1TEWcAKUW7nlcQ9rwJnwg6MfUKE/cawwPUqGp8WTbavX4/IX/k+jQsuI9XvZ9Y96ilLhTRw== openpgp:0xD85CD295"
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = ["wheel" "networkmanager"];
      shell = pkgs.zsh;
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      # Opinionated: forbid root login through SSH.
      PermitRootLogin = "no";
      # Opinionated: use keys only.
      # Remove if you want to SSH using passwords
      PasswordAuthentication = false;
    };
  };

  services.caddy = {
    enable = true;
    # package = pkgs.caddy.withPlugins {
    #   plugins = [
    #     "github.com/caddy-dns/cloudflare@v0.2.4"
    #   ];
    #   hash = "replace-this";
    # };
    settings = {
      # admin.identity.issuers.acme = {
      #  	module = "acme";
      #  	challenges.dns.provider = {
      #     name = "cloudflare";
      #     api_token = "{env.CF_API_TOKEN}";
      #  	};
      # };
    };
  };

  custom.neovim.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";
}
