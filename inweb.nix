{ lib, stdenv, fetchFromGitHub, makeBinaryWrapper }:
let
  version = "7.2.0";
in stdenv.mkDerivation {
  pname = "inweb";
  inherit version;

  src = fetchFromGitHub {
    owner = "ganelson";
    repo = "inweb";
    rev = "v${version}";
    hash = "sha256-kgyMzqGyZ1aihx8f9OCFOd2dlAUhUp98ni4rcgNrPq0=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];

  outputs = [ "out" "doc" ];

  unpackPhase = ''
    runHook preUnpack

    cp -pr --reflink=auto -- "$src" inweb
    chmod -R u+w inweb

    runHook postUnpack
  '';

  PLATFORM =
    if stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch then "macosarm"
    else if stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isi686 then "macos32"
    else if stdenv.hostPlatform.isDarwin then "macos"
    else if stdenv.hostPlatform.isLinux then "linux"
    else "unix";

  configurePhase = ''
    runHook preConfigure

    cp -f inweb/Materials/platforms/$PLATFORM.mk inweb/platform-settings.mk
    cp -f inweb/Materials/platforms/inweb-on-$PLATFORM.mk inweb/inweb.mk

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    make -f inweb/inweb.mk initial

    runHook postBuild
  '';

  shareDocName = "inweb";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/libexec/inweb"
    cp -rp --reflink=auto \
      inweb/foundation-module inweb/Languages inweb/Materials inweb/platform-settings.mk \
      "$out/libexec/inweb/"
    mkdir -p "$out/libexec/inweb/Tangled"
    cp -p --reflink=auto inweb/Tangled/inweb "$out/libexec/inweb/Tangled/inweb"
    makeBinaryWrapper "$out/libexec/inweb/Tangled/inweb" "$out/bin/inweb" \
      --add-flags -at --add-flags "$out/libexec/inweb"

    mkdir -p "$out/share/doc"
    cp -rp --reflink=auto inweb/docs "$out/share/doc/$shareDocName"

    runHook postInstall
  '';

  meta = with lib; {
    description = "A modern system for literate programming written for the Inform programming language project";
    homepage = "https://ganelson.github.io/inweb/index.html";
    license = licenses.artistic2;
    maintainers = with maintainers; [ zombiezen ];
    platforms = platforms.unix;
  };
}
