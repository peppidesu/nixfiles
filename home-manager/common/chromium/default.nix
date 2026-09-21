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
  };
}
