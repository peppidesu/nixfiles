{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{

  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
  ];

  boot.supportedFilesystems = [
    "btrfs"
    "ext4"
    "tempfs"
  ];

  environment.systemPackages = [
    inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko-install
  ];

  image.fileName = lib.mkForce "disko-nixos-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";

  networking.wireless.enable = lib.mkForce true;

  nixpkgs.overlays = [
    (final: prev: {
      # Prevent mbrola-voices (~650MB) from being on the live media
      espeak = prev.espeak.override {
        mbrolaSupport = false;
      };
    })
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHDmqN9vOXKI8lgVdmUQF2Bg7yZ6lz5tNZmSJN+syr1w peppidesu@archelon"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };
}
