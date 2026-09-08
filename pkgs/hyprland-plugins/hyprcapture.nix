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
  nlohmann_json,
  pipewire,
  qt6,
}:

mkHyprlandPlugin (finalAttrs: {
  pluginName = "hyprcapture";
  version = "0.2.8-0.56.2";

  src = fetchFromGitHub {
    owner = "gfhdhytghd";
    repo = "HyprCapture";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7OzlL6K2eqhMpOM73LO84O0JC/gLtQmDSs6i3mbYZEA=sha256-7OzlL6K2eqhMpOM73LO84O0JC/gLtQmDSs6i3mbYZEA=";
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
  ];

  cmakeFlags = [
    "-DHYPRCAPTURE_DEFAULT_HELPER_PATH=${placeholder "out"}/bin/hyprcapture-ui"
    "-DHYPRCAPTURE_TRUSTED_BIN_DIRS=${placeholder "out"}/bin"
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
