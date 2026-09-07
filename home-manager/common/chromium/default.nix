{pkgs, ...}: {
  programs.chromium = {
    enable = true;
    dictionaries = [
      pkgs.hunspellDictsChromium.en_US
    ];
    extensions = [
      # uBlock Origin
      { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; }
      # Dark reader
      { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; }
      # Bitwarden
      { id = "nngceckbapebfimnlniiiahkandclblb"; }
      # Unhook
      { id = "khncfooichmfjbepaaaebmommgaepoid"; }
    ];
    commandLineArgs = [
      "--ignore-gpu-blocklist"
      "--enable-gpu-rasterization"
      "--enable-vulkan"
      "--enable-system-notifications"
      "--pdf-use-skia-renderer"
      "--enable-unsafe-webgpu"
      "--enable-drdc"
      "--skia-graphite"
    ];
  };
}
