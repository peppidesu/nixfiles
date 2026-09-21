# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:
{
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # inputs.self.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./common
  ]
  ++ lib.optionals osConfig.profiles.graphical.enable [

  ];

  config = {
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

    # TODO: Set your username
    home = {
      username = "daklab";
      homeDirectory = "/home/daklab";
    };

    # Enable home-manager and git
    programs.home-manager.enable = true;
    programs.git.settings = {
      user.name = "Pepijn Bakker";
      user.email = "p.bakker@daklab.nl";
      user.signingkey = "23212ECB3DD3A645";
      credential = {
        helper = [
          "cache --timeout=21600"
          "oauth"
        ];
      };
    };

    home.packages = lib.optionals osConfig.profiles.graphical.enable [
      pkgs.teams-for-linux
      pkgs.git-credential-oauth
      pkgs.bitwarden-desktop
    ];

    systemd.user.services.bitwarden-desktop = {
      Unit = {
        Description = "Bitwarden Desktop Password Manager";
        After = [ "graphical-session.target" ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.bitwarden-desktop}/bin/bitwarden";
        Restart = "on-failure";
      };
    };

    # Nicely reload system units when changing configs
    systemd.user.startServices = "sd-switch";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    home.stateVersion = "25.11";
  };
}
