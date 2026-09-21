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
    inputs.self.nixosModules.greeter

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    ./hardening.nix
    ./hardware-configuration.nix
    ./disk-config.nix
    ../../common/profiles.nix
    ../../common/attic
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
  programs.dconf.enable = true;

  home-manager.users."peppidesu" = ../../home-manager/peppidesu.nix;
  home-manager.users."daklab" = ../../home-manager/daklab.nix;
  home-manager.extraSpecialArgs = { inherit inputs; };
  hardware.bluetooth.enable = true;

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = ["nix-command" "flakes"];
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

  # age.secrets.wg-key-archelon = {
  #   file = "${inputs.self.outPath}/secrets/wg-key-archelon.age";
  #   mode = "640";
  # };
  # networking.wg-quick.interfaces.wg0 = (import ../../common/wg.nix moduleArgs).peers.archelon;

  networking = {
    hostName = "archelon";
    networkmanager.enable = true;
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
      # TODO: You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = ["wheel" "networkmanager"];
      shell = pkgs.zsh;
    };
    daklab = {
      # TODO: You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = ["wheel" "networkmanager" "docker"];
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

  services.homepage-dashboard = {
    enable = true;
  };

  services.fprintd.enable = true;

  environment.systemPackages = [
    pkgs.fprintd
  ];
  environment.sessionVariables = {
    AQ_NO_MODIFIERS = "1";
  };
  security.pam.services.greetd.fprintAuth = true;
  security.pam.services.gtklock = { };
  security.polkit.enable = true;

  services.udev.packages = [ pkgs.yubikey-personalization ];

  peppidesu.neovim.enable = true;

  powerManagement.enable = true;

  services.pipewire.wireplumber.extraConfig."10-dmic-node-props" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          {
            # Target only the AMD ACP DMIC capture device
            "node.name" = "~alsa_input.pci-0000_c1_00.5.*"; # or matching your acp-pdm-mach node name
          }
        ];
        actions = {
          update-props = {
            "audio.channels" = 2;
            "audio.position" = "[ FL FR ]";
          };
        };
      }
    ];
  };

  systemd.services.load-fw16-mic = {
    description = "Load AMD ACP DMIC modules after boot";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      /run/current-system/sw/bin/modprobe snd_acp_pci
      /run/current-system/sw/bin/modprobe snd_acp70
    '';
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "26.05";
}
