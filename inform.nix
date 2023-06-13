{ lib, stdenv, callPackage, fetchFromGitHub, makeBinaryWrapper }:
let
  version = "10.1.2";

  inweb = callPackage ./inweb.nix {};
in stdenv.mkDerivation {
  pname = "inform7";
  inherit version;

  src = fetchFromGitHub {
    owner = "ganelson";
    repo = "inform";
    rev = "v${version}";
    hash = "sha256-EkUTQNm0Hetk7IHxF44aZCZyCRfNEMzdQQ0AwrjHXP8=";
  };

  nativeBuildInputs = [ inweb makeBinaryWrapper ];

  sourceRoot = "inform";

  unpackPhase = ''
    runHook preUnpack

    cp -pr --reflink=auto -- "$src" inform
    chmod -R u+w inform

    ln -s "$(dirname $(command -v inweb) )/../libexec/inweb" inweb

    runHook postUnpack
  '';

  # Configure and build phases adapted from scripts/first.sh.
  configurePhase = ''
    runHook preConfigure

    inweb -prototype scripts/inform.mkscript -makefile makefile
    make makers

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    make force
    make -f inform6/inform6.mk interpreters

    runHook postBuild
  '';

  binaries = [
    "inblorb"
    "inbuild"
    "inform6"
    "inform7"
    "inter"
  ];

  shareDocName = "inform7";

  outputs = [ "out" "doc" ];

  installPhase = ''
    runHook preInstall

    for i in $binaries; do
      mkdir -p "$out/bin"
      mkdir -p "$out/libexec/inform7/$i/Tangled"
      cp -rp --reflink=auto "$i/Tangled/$i" "$out/libexec/inform7/$i/Tangled/$i"

      if [[ "$i" = inform6 ]]; then
        ln -s "$out/libexec/inform7/$i/Tangled/$i" "$out/bin/$i"
      else
        makeBinaryWrapper "$out/libexec/inform7/$i/Tangled/$i" "$out/bin/$i" \
          --add-flags -at --add-flags "$out/libexec/inform7/$i"
      fi

      if [[ -e "$i/Tangled/Syntax.preform" ]]; then
        cp -rp --reflink=auto "$i/Tangled/Syntax.preform" "$out/libexec/inform7/$i/Tangled/Syntax.preform"
      fi
    done

    for i in inform7/Internal inter/Pipelines; do
      cp -rp --reflink=auto "$i" "$out/libexec/inform7/$i"
    done

    mkdir -p "$out/share/doc"
    cp -rp --reflink=auto docs "$out/share/doc/$shareDocName"

    runHook postInstall
  '';

  meta = with lib; {
    description = "A design system for interactive fiction";
    homepage = "http://inform7.com/";
    license = licenses.artistic2;
    maintainers = with maintainers; [ zombiezen ];
    platforms = platforms.unix;
    # never built on aarch64-darwin since first introduction in nixpkgs
    broken = (stdenv.isDarwin && stdenv.isAarch64) || (stdenv.isLinux && stdenv.isAarch64);
  };

  passthru.inweb = inweb;
}
