# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
moduleArgs@{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # inputs.self.nixosModules.example
    inputs.self.nixosModules.neovim
    inputs.self.nixosModules.caddy
    inputs.self.nixosModules.netbird

    # Or modules from other flakes (such as nixos-hardware):
    inputs.agenix.nixosModules.default
    inputs.vpn-confinement.nixosModules.default
    inputs.flurry.nixosModules.default

    ./hardening.nix

    ./jellystack.nix
    # ./ksp.nix
    ./immich.nix
    ./minecraft.nix
    ./radicale.nix
    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
    ./factorio.nix
    ./flurry.nix
    ../../common/profiles.nix
  ];
  home-manager.users."peppidesu" = ../../home-manager/peppidesu.nix;
  home-manager.users."noa" = ../../home-manager/noa.nix;
  home-manager.extraSpecialArgs = { inherit inputs; };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      inputs.self.overlays.additions
      inputs.self.overlays.modifications

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

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        # Opinionated: disable global registry
        # flake-registry = "";
        # Workaround for https://github.com/NixOS/nix/issues/9574
        nix-path = config.nix.nixPath;
        trusted-users = [
          "peppidesu"
          "noa"
        ];
      };
      # Opinionated: disable channels
      channel.enable = false;

      # Opinionated: make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

  networking = {
    hostName = "lagoon";
    tempAddresses = "disabled";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
      ];
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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHDmqN9vOXKI8lgVdmUQF2Bg7yZ6lz5tNZmSJN+syr1w peppidesu@archelon"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAqaiJUEzKbdGcIPzQwPFvTn1Gh5E00a/6MDs5JtBwOC peppidesu@megalodon"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBJKQeBymU0nYPFrA2dJ4QMfhYQb7BqR6N34HxjJBDQS root@ferry"
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      shell = pkgs.zsh;
    };
    noa = {
      hashedPassword = "$6$rounds=512400$g/s4dcRttXi4ux6c$Z6pKnhJXcWxv0TBSMtvJu5.piETdUBSgBVN7oDPKiQV.lbTYz1r.0XQLwMYxzcvaaX0DL6Iw/SEUTiC2M50wC/";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDehPFoo1yNfTS8PdK98KqcLqe4p+gjbV8DE9Gb3j3s6h3aWbGQdSkk4v68FXb1IjaIFpSNKmxhUSfdbkrzjsW0XhDDJ75EIjNpYRIZWlLJrtMbPUvgDBAHocvpWY8AZs1TuxCC2NnCbfo+inNQv+fkIe9Tmh16A8RIAHRxBOyO6KOlOog9hBuBwk4T2Z0hMWCTmMWZean/J4qtMcHiMTmjZg/wx3fk5GNVItyjKWlTBghgzxV1YTsNNTha9wuDVAM3o5fTR8/XvJXyMxinB4DgxcK+x1v+3DwYaEXIKSTMOY7SMJxnMEV9klU8904J0MHyrDHOERvnY6W68T5aNbW7Q1A5Pz6hsTrqUG0p3hEIgwSQNnt5/p0Q/nLNXs3X7xEp+u9KwEoPp/u8Zq/m9cbKtNyAAYFZWDhyV6odenNLcL812uhgC9MMTvWGNkpcbTbGRSORwH820viccJILpHAvqsZc2DuS6axasoTTf1tR/uoN5I80Jj3pL2dvr86D5SIxustloKEkK8+CweG+hFJC4gaOp7z7O3ugjkWDOPjfiJfaZoLvxZ+E7z4v+hCJaEWGrYdiX6HHFT7flL4oMczxuUE05SSRwH3n+RNw4X9Rbjm9Fx50imY1PuqA5Ex+iD3xD2V/Fv7TeNrAiltnZhy7AIY6zt81ED+i2QRYveZqiw== openpgp:0xACFC4FF3"
      ];
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

  services.roon-server = {
    enable = true;
    openFirewall = true;
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

  peppidesu.neovim.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";
}
