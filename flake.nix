{
  description = "Peppi's NixOS flake";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Nixvim
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    flurry.url = "git+https://git.geenit.nl/noa/flurry.git";
    flurry.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nixcord.url = "github:4evy/nixcord";
    nixcord.inputs.nixpkgs.follows = "nixpkgs";

    hardware.url = "github:NixOS/nixos-hardware/master";

    pepoapkgs = {
      url = "github:itepastra/pepoapkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    attic.url = "github:zhaofengli/attic";
    attic.inputs.nixpkgs.follows = "nixpkgs";

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    obsidian-extensions = {
      url = "github:karaolidis/nix-obsidian-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    septabee = {
      url = "github:Ap6661/septabee-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
  };

  outputs =
    {
      nixpkgs,
      ...
    }@inputs:
    let
      # Supported systems for your flake packages, shell, etc.
      systems = [
        "aarch64-linux"
        # "i686-linux"
        "x86_64-linux"
        # "aarch64-darwin"
        # "x86_64-darwin"
      ];
      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      # Your custom packages
      # Accessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      # Formatter for your nix files, available through 'nix fmt'
      # Other options beside 'alejandra' include 'nixpkgs-fmt'
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };
      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = import ./modules/nixos;
      # Reusable home-manager modules you might want to export
      # These are usually stuff you would upstream into home-manager
      homeManagerModules = import ./modules/home-manager;

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {
        lagoon = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./machines/lagoon/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };
        ferry = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./machines/ferry/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };
        archelon = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./machines/archelon/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };
        megalodon = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./machines/megalodon/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };
        clam = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [ ./machines/clam/configuration.nix ];
        };
        debug = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            inputs.agenix.nixosModules.default
            inputs.home-manager.nixosModules.default
            inputs.vpn-confinement.nixosModules.default
            inputs.flurry.nixosModules.default
            inputs.pepoapkgs.nixosModules.default
          ];
        };
      };
    };
}
