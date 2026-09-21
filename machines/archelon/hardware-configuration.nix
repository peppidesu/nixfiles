{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [
    "kvm-amd"
    "snd_acp_pci"
    "snd_acp70"
  ];
  boot.extraModulePackages = [ ];
  boot.loader.systemd-boot.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Framework 16 — Ryzen AI 300 (Strix / ACP 7.0)
  # boot.kernelModules = [
  #   "snd_acp_config"
  #   "snd_acp_legacy_common"
  #   "snd_acp_pci"
  #   "snd_acp_legacy_mach"
  # ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    # wireplumber.extraConfig.no-ucm = {
    #   "monitor.alsa.properties" = {
    #     "alsa.use-ucm" = false;
    #   };
    # };
  };
}
