{
  stdenv,
  fetchFromGitHub,

  meson,
  ninja,
  pkg-config,
  gtk4,
  libadwaita,
  gtk4-layer-shell,
  json-glib,
  bluez,
  pulseaudio,
  libuuid
}: stdenv.mkDerivation rec {
  pname = "bluetooth-manager-sidebar";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Relz";
    repo = "bluetooth-manager-sidebar";
    rev = "v${version}";
    hash = "sha256-KQuH6tLpwZMLwGgQpAnEp5/ENxLWvDiwMUKmgVK6mQE=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    gtk4
    libadwaita
    gtk4-layer-shell
    json-glib
    bluez
    pulseaudio
    libuuid
  ];

  meta = {
    mainProgram = "bm-sidebar";
  };
}
