{
  neovim = import ./neovim.nix;
  caddy = import ./caddy.nix;
  netbird = import ./netbird.nix;
  greeter = import ./greeter;
  jellyfin-ffmpeg-shim = import ./jellyfin-ffmpeg-shim.nix;
  minecraft = import ./minecraft.nix;
}
