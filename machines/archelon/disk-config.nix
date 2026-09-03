{inputs, ...}: {
  imports = [inputs.disko.nixosModules.disko];

  boot.kernel.sysctl = {
    "vm.swappiness" = 10; # swap as little as possible to protect ssd health
  };

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nmve0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1024M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" "nosuid" "nodev" "noexec" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "vault";
                enrollFido2 = true;
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd:4"
                        "noatime"
                      ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "compress=zstd:0"
                        "noatime"
                      ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd:4"
                        "noatime"
                        "nosuid"
                      ];
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "32G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
