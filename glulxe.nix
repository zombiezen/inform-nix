{ stdenv, lib, fetchFromGitHub, ncurses }:

let
  version = "0.6.0";

  glkterm =
    let
      pname = if ncurses.unicodeSupport then "glktermw" else "glkterm";
      version = "1.0.4";
    in stdenv.mkDerivation {
      inherit pname version;

      src = fetchFromGitHub {
        owner = "erkyrath";
        repo = "glkterm";
        rev = "glkterm-${version}" + (if ncurses.unicodeSupport then "-widechar" else "");
        hash = if ncurses.unicodeSupport
          then "sha256-T6MC3wb9QYQOYJgQra16oFoVsJ5YbXbHgK3DZIn6Lqc="
          else "sha256-EL7jzqlBa1pRNspyxaIMGLfwf5+/nq8Wyi0UCM7pPCw=";
      };

      propagatedBuildInputs = [ ncurses ];

      installPhase = ''
        runHook preInstall

        mkdir -p "$out/lib"
        cp -p --reflink=auto lib$pname.a "$out/lib/lib$pname.a"

        mkdir -p "$out/include"
        cp -p --reflink=auto *.h Make.$pname "$out/include/"

        runHook postInstall
      '';

      passthru.makefileName = "Make.${pname}";
    };
in stdenv.mkDerivation {
  pname = "glulxe";
  inherit version;

  src = fetchFromGitHub {
    owner = "erkyrath";
    repo = "glulxe";
    rev = "glulxe-${version}";
    hash = "sha256-+CynMr34YnL0NelaF5rkwYf1J7XjLRY8SxzRvwtvDR0=";
  };

  buildInputs = [ glkterm ];

  makeFlags = [
    "GLKLIBDIR=${glkterm}/lib"
    "GLKINCLUDEDIR=${glkterm}/include"
    "GLKMAKEFILE=${glkterm.makefileName}"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp -p --reflink=auto glulxe "$out/bin/glulxe"

    runHook postInstall
  '';
}
