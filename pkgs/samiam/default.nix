{ lib
, stdenv
, fetchFromGitHub
, jdk8
, jre8
, makeWrapper
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "samiam";
  version = "unstable-2023-06-27";

  src = fetchFromGitHub {
    owner = "uclareasoning";
    repo = "SamIam";
    # Pin a commit hash for reproducibility; "main" also works.
    rev = "main";
    hash = "sha256-ClrTdhXBoiwxmMmrGblZ+pxqAgMETEXOEit8QSSlIbU=";
  };

  # SamIam is Java 1.4/1.5 source. jdk8 is the newest JDK whose javac
  # still accepts -source/-target 1.4 and 1.5.
  nativeBuildInputs = [ jdk8 makeWrapper ];
  buildInputs = [ jre8 ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    # ---- inflib: two-pass compile (1.4 list, then 1.5 list) ----
    mkdir -p inflib/compiled
    ( cd inflib
      javac -source 1.4 -target 1.4 -d compiled @files.txt
      javac -source 1.5 -target 1.5 -d compiled -classpath compiled @files5.txt
    )

    # ---- samiam: two-pass compile, against inflib ----
    mkdir -p samiam/compiled
    ( cd samiam
      javac -source 1.4 -target 1.4 -d compiled \
        -classpath ../inflib/compiled @files.txt
      javac -source 1.5 -target 1.5 -d compiled \
        -classpath ../inflib/compiled:compiled @files5.txt
    )

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/java

    # inflib.jar (bundles the XSD resource)
    ( cd inflib
      jar cf $out/share/java/inflib.jar \
        edu/ucla/belief/io/xmlbif/bif.xsd \
        -C compiled .
    )

    # samiam.jar (bundles images/, sets the main class)
    ( cd samiam
      echo "Main-Class: edu.ucla.belief.ui.UI" > "$TMPDIR/manifest.mf"
      jar cfm $out/share/java/samiam.jar "$TMPDIR/manifest.mf" \
        images -C compiled .
    )

    mkdir -p $out/bin
    makeWrapper ${jre8}/bin/java $out/bin/samiam \
      --add-flags "-Xms8m -Xmx512m" \
      --add-flags "-cp $out/share/java/samiam.jar:$out/share/java/inflib.jar" \
      --add-flags "edu.ucla.belief.ui.UI"

    runHook postInstall
  '';

  meta = {
    description = "SamIam: modeling, inference and sensitivity analysis for Bayesian networks";
    homepage = "http://reasoning.cs.ucla.edu/samiam/";
    license = lib.licenses.free; # verify against the repo's LICENSE file
    platforms = lib.platforms.unix;
    mainProgram = "samiam";
  };
})
