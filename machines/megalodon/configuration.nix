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
    inputs.self.nixosModules.greeter
    inputs.self.nixosModules.netbird
    inputs.septabee.nixosModules.default

    # Or modules from other flakes (such as nixos-hardware):
    inputs.agenix.nixosModules.default
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-cpu-amd-pstate
    inputs.hardware.nixosModules.common-cpu-amd-zenpower
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.pepoapkgs.nixosModules.attic-toggler

    ./hardening.nix
    ./hardware-configuration.nix
    ./disk-config.nix
    ../../common/profiles.nix
  ];

  peppidesu.greeter.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  virtualisation.docker.enable = true;

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

  profiles.graphical.enable = true;
  profiles.graphical.games = true;

  programs.dconf.enable = true;

  home-manager.users."peppidesu" = ../../home-manager/peppidesu.nix;
  home-manager.users."daklab" = ../../home-manager/daklab.nix;
  home-manager.extraSpecialArgs = { inherit inputs; };
  hardware.bluetooth.enable = true;

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      package = pkgs.nixVersions.latest;
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
      };
      # Opinionated: disable channels
      channel.enable = false;

      # Opinionated: make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

  services.resolved.enable = true;
  networking = {
    hostName = "megalodon";
    networkmanager.enable = true;
    networkmanager.dns = "systemd-resolved";
    firewall.enable = true;
    tempAddresses = "disabled";
  };

  programs.zsh.enable = true;
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
    enableSSHSupport = true;
  };

  users.users = {
    peppidesu = {
      hashedPassword = "$6$rounds=65536$.nevQkbHOU4EN1my$orZCLTiCeAz8Tmd1OTPJrnF1MIpQFj/sOYP1q3oa/pBBKZ2ft5aWJd5SP7k2UdfbXSZH4S2iVQEQs62BJv3Sp.";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
      ];
      shell = pkgs.zsh;

    };
    daklab = {
      hashedPassword = "$6$rounds=65536$rRJtWk3Ir53IKUpE$7luUO9oVsLD5t8OoZHuLdthQAdEi57XLbSKiCLR4Yb3Au0rSs062zeIFH06s71/JgS3d5nhZxWYNtqF94e.Xh0";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
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

  programs.uwsm = {
    enable = false;
  };
  environment.systemPackages = [
    pkgs.fprintd
  ];

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.gtklock = { };
  security.polkit.enable = true;

  services.udev.packages = [ pkgs.yubikey-personalization ];

  peppidesu.neovim.enable = true;

  # Septabee's options and their defaults
  programs.septabee = {
    enable = true;
    wayland-deps = true; # Install wayland only dependencies
    version = "latest"; # like [ "latest" "B_T1" "B_T2" ... ]
    offline = true; # Doesn't require downloading LLVM stuff
  };

  age.secrets."attic/anemone" = {
    file = ../../secrets/attic-anemone.age;
    mode = "600";
  };

  services.attic-toggler = {
    enable = true;
    force = true;
    token = config.age.secrets."attic/anemone".path;
    publicKey = "anemone:f/wBQ8yB5geTn96NjwRfbcoEvr8QuykN0iu0Rf2zUC8=";
    watchStore = {
      enable = true;
    };
  };

  hardware.opentabletdriver.enable = true;
  hardware.opentabletdriver.daemon.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "26.05";
}
