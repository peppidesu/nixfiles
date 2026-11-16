{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  python3,
  jellyfin-ffmpeg,
}:

let
  # Pin this to a commit SHA for a reproducible build; "main" works but moves.
  rev = "main";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "jellyfin-ffmpeg-shim";
  version = "0.1.0-unstable-2026-11-16";

  src = fetchFromGitHub {
    owner = "bjlaur";
    repo = "jellyfin-ffmpeg-shim";
    inherit rev;
    hash = "sha256-Ezb6KMGg61W25OaSynsNCMjyLXvGWGiTAoiWehAUXTc=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  # The script has a hardcoded emergency fallback of /usr/lib/jellyfin-ffmpeg/ffmpeg
  # used when the config is missing/invalid. Point it at the Nix package instead.
  postPatch = ''
    substituteInPlace jellyfin-ffmpeg-shim \
      --replace-quiet '"/usr/lib/jellyfin-ffmpeg/ffmpeg"' \
                     '"${jellyfin-ffmpeg}/bin/ffmpeg"'
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 jellyfin-ffmpeg-shim \
      $out/libexec/jellyfin-ffmpeg-shim/jellyfin-ffmpeg-shim
    install -Dm644 shim.json.example \
      $out/share/jellyfin-ffmpeg-shim/shim.json.example
    install -Dm644 README.md $out/share/doc/jellyfin-ffmpeg-shim/README.md
    install -Dm644 LICENSE   $out/share/licenses/jellyfin-ffmpeg-shim/LICENSE

    makeWrapper $out/libexec/jellyfin-ffmpeg-shim/jellyfin-ffmpeg-shim \
      $out/bin/jellyfin-ffmpeg-shim \
      --prefix PATH : ${lib.makeBinPath [ python3 ]} \
      --set-default JELLYFIN_SHIM_CONFIG /etc/jellyfin/shim.json

    # Jellyfin resolves ffprobe as a sibling of the --ffmpeg path, so the
    # shim must be exposed as bin/ffmpeg next to a real bin/ffprobe.
    ln -s jellyfin-ffmpeg-shim $out/bin/ffmpeg
    ln -s ${jellyfin-ffmpeg}/bin/ffprobe $out/bin/ffprobe

    runHook postInstall
  '';


  meta = {
    description = "Jellyfin FFmpeg shim for selective HDR-to-HDR transcoding";
    homepage = "https://github.com/bjlaur/jellyfin-ffmpeg-shim";
    license = lib.licenses.mit;
    mainProgram = "jellyfin-ffmpeg-shim";
    platforms = lib.platforms.linux;
  };
})
