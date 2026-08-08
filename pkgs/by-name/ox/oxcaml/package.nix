{
  lib,
  stdenv,
  clangStdenv,
  fetchFromGitHub,
  autoconf,
  gfortran,
  linkFarm,
  llvm,
  ocaml-ng,
  parallel,
  pkg-config,
  removeReferencesTo,
  rsync,
  which,
  libtool,
  cctools,

  # OxCaml build variants. The defaults match what oxcaml's own default.nix and
  # CI build; the flags are passed straight through to ./configure.
  addressSanitizer ? false,
  dev ? false,
  flambdaInvariants ? false,
  framePointers ? addressSanitizer,
  multidomain ? false,
  ocamltest ? true,
  pollInsertion ? false,
  stackChecks ? false,
  warnError ? true,
  syntaxQuotations ? false,
}:

let
  # OxCaml bootstraps itself with a vanilla OCaml 5.x compiler. Upstream pins
  # 5.4.0 plus an in-tree patch to asmcomp/cmm_helpers.ml
  # (tools/ci/local-opam/packages/ocaml-base-compiler/) that fixes aarch64
  # assembly generation in the *boot* compiler. nixpkgs' unmodified 5.4 works
  # on x86_64 and is already cached; the aarch64 patch would have to be
  # reinstated before meta.platforms can grow an aarch64 entry.
  bootCompiler = ocaml-ng.ocamlPackages_5_4.ocaml;

  dune = ocaml-ng.ocamlPackages_4_14.dune_3;

  # OxCaml's configure hard-requires menhir 20231231 exactly. That release
  # predates both the menhirGLR package and the base/Installation.ml that
  # nixpkgs' menhir-suggest-menhirLib.patch targets, so drop both and point
  # menhir at menhirLib with a symlink instead.
  menhirLib = ocaml-ng.ocamlPackages_4_14.menhirLib.override { version = "20231231"; };
  menhirSdk = ocaml-ng.ocamlPackages_4_14.menhirSdk.override { inherit menhirLib; };
  menhir =
    (ocaml-ng.ocamlPackages_4_14.menhir.override { inherit menhirLib menhirSdk; }).overrideAttrs
      {
        patches = [ ];
        buildInputs = [
          menhirLib
          menhirSdk
        ];
        postInstall = ''
          ln -s ${menhirLib}/lib/ocaml/*/site-lib/menhirLib $out/lib/
        '';
      };

  # Some bigarray tests need a Fortran compiler, but putting gfortran directly
  # in nativeBuildInputs shadows `as` and `objcopy` from the stdenv, which the
  # build needs to keep.
  gfortranOnly = linkFarm "gfortran-only" { "bin/gfortran" = lib.getExe gfortran; };

  mkFlag = bool: name: if bool then "--enable-${name}" else "--disable-${name}";

  effectiveStdenv = if addressSanitizer then clangStdenv else stdenv;
in

effectiveStdenv.mkDerivation {
  pname = "oxcaml";
  version = "5.2.0+ox";

  src = fetchFromGitHub {
    owner = "oxcaml";
    repo = "oxcaml";
    # Pinned by commit rather than by the 5.2.0minus-40 tag: OxCaml's release
    # tags are mutable.
    rev = "9cfe2002ce39e1657f374e6c9146af63205f1d3d";
    hash = "sha256-alTHtiNroFoOSvRk00QN7yLgYBEljSqqknueCkShCJk=";
  };

  configureFlags = [
    "--cache-file=/dev/null"
    "--with-objcopy=${llvm}/bin/llvm-objcopy"
    "--enable-assembler-suitable-for-dissector=${llvm}/bin/llvm-mc"
    (mkFlag addressSanitizer "address-sanitizer")
    (mkFlag dev "dev")
    (mkFlag flambdaInvariants "flambda-invariants")
    (mkFlag framePointers "frame-pointers")
    (mkFlag multidomain "multidomain")
    (mkFlag pollInsertion "poll-insertion")
    (mkFlag stackChecks "stack-checks")
    (mkFlag warnError "warn-error")
    (mkFlag ocamltest "ocamltest")
    (mkFlag syntaxQuotations "syntax-quotations")
  ];

  nativeBuildInputs = [
    autoconf
    bootCompiler
    dune
    gfortranOnly
    menhir
    parallel
    pkg-config
    removeReferencesTo
    rsync
    which
  ]
  ++ (if effectiveStdenv.hostPlatform.isDarwin then [ cctools ] else [ libtool ]);

  buildInputs = [
    llvm # llvm-objcopy is used for debug info
  ];

  enableParallelBuilding = true;
  dontStrip = true;
  separateDebugInfo = false;

  # Disable the _multioutConfig hook, which would add --libdir=$out/lib to
  # configureFlags; OCaml's configure expects --libdir to be $out/lib/ocaml.
  setOutputFlags = false;

  preConfigure = ''
    rm -rf _build _install _runtest

    # autoreconfHook is not usable here: libtoolize and autoheader are
    # incompatible with ocaml-flambda.
    autoconf --force
  '';

  # The full ocamltest suite; not run by default.
  checkPhase = lib.optionalString ocamltest ''
    runHook preCheck
    make ci
    runHook postCheck
  '';

  postInstall = ''
    $out/bin/generate_cached_generic_functions.exe $out/lib/ocaml/cached-generic-functions

    # Unused build artifacts.
    rm -f $out/bin/dumpobj.byte
    rm -f $out/bin/extract_externals.byte
    rm -f $out/bin/generate_cached_generic_functions.exe
    rm -f $out/bin/ocamlcp
    rm -f $out/bin/ocamlmklib.byte
    rm -f $out/bin/ocamlmktop.byte
    rm -f $out/bin/ocamlobjinfo.byte
    rm -f $out/bin/ocamlopt.byte
    rm -f $out/bin/ocamlprof
    rm -f $out/lib/ocaml/expunge
  '';

  postFixup = ''
    remove-references-to -t ${dune} $out/lib/ocaml/Makefile.config
  '';

  passthru = {
    # Read by nixpkgs' findlib and the OCaml build-support helpers.
    nativeCompilers = true;
    inherit bootCompiler;
  };

  meta = {
    description = "Performance-focused fork of OCaml, home of Flambda 2";
    homepage = "https://oxcaml.org/";
    # Like OCaml itself: LGPL 2.1 with a linking exception.
    license = lib.licenses.lgpl21;
    mainProgram = "ocaml";
    maintainers = [ ];
    # Upstream CI also covers aarch64-linux and aarch64-darwin, but those need
    # the boot-compiler patch described above and have not been built here yet.
    platforms = [ "x86_64-linux" ];
    broken = framePointers && !effectiveStdenv.hostPlatform.isx86_64;
  };
}
