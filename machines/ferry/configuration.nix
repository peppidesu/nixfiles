# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
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

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    ./dns.nix
    ./hardware-configuration.nix
    ./hardening.nix
  ];

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
  home-manager.users."peppidesu" = ../../home-manager/peppidesu.nix;
  home-manager.extraSpecialArgs = { inherit inputs; };

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

  boot = {
     kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
     initrd.availableKernelModules = {
       dw-hdmi = lib.mkForce false;
       dw-mipi-dsi = lib.mkForce false;
       rockchipdrm = lib.mkForce false;
       rockchip-rga = lib.mkForce false;
       phy-rockchip-pcie = lib.mkForce false;
       pcie-rockchip-host = lib.mkForce false;
       pwm-sun4i = lib.mkForce false;
       sun4i-drm = lib.mkForce false;
       sun8i-mixer = lib.mkForce false;
     };
     loader = {
       grub.enable = false;
       generic-extlinux-compatible.enable = true;
     };
   };

  networking = {
    hostName = "ferry";
    nameservers = [ "127.0.0.1" "::1" ];

    networkmanager.enable = true;
    networkmanager.dns = "none";

    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ 53 ];
    };
  };
  services.resolved.enable = false;

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

  age.secrets.wg-key-ferry = {
    file = "${inputs.self.outPath}/secrets/wg-key-ferry.age";
    mode = "640";
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.90.0.1/16" "fc00:90:90:90::0:1/64" ];
      listenPort = 51820;
      privateKeyFile = config.age.secrets.wg-key-ferry.path;

      peers = [
        {
          publicKey = "tpajiBBjNW6RBahfZCttqCxEBu536ZqmuUMzCm93bxI=";
          allowedIPs = [ "10.90.0.2/32" "fc00:90:90:90::0:2/128" ];
        }
      ];
    };
  };

  systemd.services.wireguard-wg0.serviceConfig = {
    DynamicUser = true;
  };
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";
}
