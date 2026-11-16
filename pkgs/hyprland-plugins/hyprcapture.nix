{
  lib,
  cmake,
  fetchFromGitHub,
  fftw,
  ffmpeg,
  glib,
  hyprland,
  kdePackages,
  libpulseaudio,
  lua,
  mkHyprlandPlugin,
  nix-update-script,
  gpu-screen-recorder,
  nlohmann_json,
  pipewire,
  qt6,
  libultrahdr,
  opencv,
}:

mkHyprlandPlugin (finalAttrs: {
  pluginName = "hyprcapture";
  version = "0.6.0-v0.57.0";

  src = fetchFromGitHub {
    owner = "gfhdhytghd";
    repo = "HyprCapture";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M3YB76XNiuN37ARgicl5ImEhiRHgNvxWu9OtxyhunsI=";
  };

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    fftw
    ffmpeg
    glib
    kdePackages.layer-shell-qt
    libpulseaudio
    lua
    nlohmann_json
    pipewire
    qt6.qtbase
    qt6.qtsvg
    qt6.qtwayland
    libultrahdr
    opencv
    gpu-screen-recorder
  ];

  cmakeFlags = [
    "-DHYPRCAPTURE_DEFAULT_HELPER_PATH=${placeholder "out"}/bin/hyprcapture-ui"
    "-DHYPRCAPTURE_TRUSTED_BIN_DIRS=${placeholder "out"}/bin"
    "-DHYPRCAPTURE_GAINMAP_HEIC=OFF" # https://github.com/NixOS/nixpkgs/issues/573375
  ];

  dontStrip = true;

  # Run only the unit tests that do not require a compositor, audio server,
  # network model downloads, or GPU DMA-BUF export.
  preCheck = ''
    export QT_QPA_PLATFORM=offscreen
  '';

  checkPhase = ''
    runHook preCheck

    ctest --test-dir build --output-on-failure \
      -E '(aec-overload|hyprcapture-sound-ui-test|hyprcapture-audio-finalize-test|hyprcapture-recording-timestamps-test|hyprcapture-window-gpu-export-test)'

    runHook postCheck
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/gfhdhytghd/HyprCapture";
    description = "Hyprland-only screenshot overlay and capture tool";
    license = lib.licenses.gpl3;
    inherit (hyprland.meta) platforms;
    maintainers = [ ];
  };
})
