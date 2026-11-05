{ ... }:
{
  services.beesd.filesystems.silo = {
    spec = "/silo";
    # 1 GiB of hash table covers roughly 1 TiB of unique data at 128 KiB extents
    hashTableSizeMB = 4096;
    verbosity = "info";
    extraOptions = [
      "--thread-count"
      "2"
      "--loadavg-target"
      "4"
    ];
  };
}
