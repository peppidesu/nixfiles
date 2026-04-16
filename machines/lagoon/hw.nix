# This is just an example, you should generate yours with nixos-generate-config and put it in here.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.loader.systemd-boot.enable = true;


  fileSystems."/silo" =
    { device = "/dev/mapper/2xWD2TB-silo";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  fileSystems."/silo/backup" =
    { device = "/dev/mapper/2xWD2TB-silo";
      fsType = "btrfs";
      options = [ "subvol=@backup" ];
    };

  fileSystems."/silo/docs" =
    { device = "/dev/mapper/2xWD2TB-silo";
      fsType = "btrfs";
      options = [ "subvol=@docs" ];
    };

  fileSystems."/silo/cdn" =
    { device = "/dev/mapper/2xWD2TB-silo";
      fsType = "btrfs";
      options = [ "subvol=@cdn" ];
    };

  fileSystems."/silo/media" =
    { device = "/dev/mapper/2xWD2TB-silo";
      fsType = "btrfs";
      options = [ "subvol=@media" ];
    };

  fileSystems."/mnt/nfs/synology/series" =
    { device = "192.168.1.101:/volume1/series";
      fsType = "nfs4";
    };

  fileSystems."/mnt/nfs/synology/docu" =
    { device = "192.168.1.101:/volume2/docu";
      fsType = "nfs4";
    };

  fileSystems."/mnt/nfs/synology/movies" =
    { device = "192.168.1.101:/volume1/movies";
      fsType = "nfs4";
    };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;


}
