# OxCaml-specific deltas to the OCaml package scope.
#
# This is the *only* file that differs between ocamlPackages_oxcaml and a stock
# mkOcamlPackages set, so none of the vanilla ocamlPackages_* sets can be
# affected by anything here.
#
# There are two kinds of change:
#
#   1. Libraries that need OxCaml compatibility patches. OxCaml extends OCaml
#      with a mode system (locality, portability, uniqueness) and an extended
#      Parsetree, so a number of libraries do not build unmodified. Where
#      oxcaml/opam-repository already carries a recipe, its patches are reused
#      verbatim (./opam-repository.nix, ./patch-sets.nix); the handful of fixes
#      that exist nowhere upstream are vendored in ./patches.
#
#   2. Test suites disabled where OxCaml's stricter mode checking rejects the
#      *test* sources while the library itself is fine. Each carries a reason.
#
# Everything here is below ppxlib in the dependency graph. OxCaml needs a
# patched ppxlib, which in turn needs a ppxlib_jane that links ppxlib_ast
# instead of ppxlib (the v0.17 ppxlib_jane propagates ppxlib and so cannot break
# the cycle), so ppxlib and everything above it -- sedlex, js_of_ocaml,
# gen_js_api -- arrives together with the Jane Street set.
{
  lib,
  fetchFromGitHub,
}:

final: prev:

let
  oxOpam = import ./opam-repository.nix { inherit fetchFromGitHub; };
  inherit (oxOpam) patchesFor;
  patchSets = import ./patch-sets.nix;
in

{
  ##############################################################################
  # Packages replaced wholesale by their oxopam recipe
  ##############################################################################

  # The Jane Street ppx rewriters use Re.Pcre, which OxCaml's portability
  # checker rejects; the oxopam patches annotate the API @@ portable.
  re = final.buildDunePackage {
    pname = "re";
    version = "1.14.0+ox";
    src = fetchFromGitHub {
      owner = "ocaml";
      repo = "ocaml-re";
      rev = "cb63cdf6d355d7eff97c88c0cf90dd567a0faf06";
      hash = "sha256-xE2ZDEvXXxgNTzFNmh+fEGgz/xir8bnPfF+CnuAgibQ=";
    };
    patches = patchesFor "re/re.1.14.0+ox" patchSets.re;
    doCheck = false; # requires ounit2, not in the dune -p closure
    propagatedBuildInputs = [ final.seq ];
  };

  ##############################################################################
  # Existing packages that only need the oxopam patches applied
  ##############################################################################

  # Uutf.String.fold_utf_8 has to accept a local_ folder for textutils, and its
  # internal tables are contended under OxCaml's portability checking.
  uutf = prev.uutf.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ patchesFor "uutf/uutf.1.0.4+ox" patchSets.uutf;
  });

  # Stock Z.of_string and friends are nonportable under OxCaml. oxopam builds
  # the avsm/zarith oxcaml branch, which annotates the API.
  zarith = prev.zarith.overrideAttrs (old: {
    src = fetchFromGitHub {
      owner = "avsm";
      repo = "zarith";
      rev = "50e84d371ee53e9ff62e4e7fbf17bcb903d2d846";
      hash = "sha256-+JLfOF+GCT9cfCDaIkqxMHvR0Fy6dX99F4bHIk4USn0=";
    };
  });

  # length_utf8 partially applies Uutf.String.fold_utf_8, which local_ mode
  # rejects. The library builds; its own test suite asserts on source positions
  # that OxCaml reports differently.
  alcotest = prev.alcotest.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ patchesFor "alcotest/alcotest.1.9.0+ox" patchSets.alcotest;
    doCheck = false;
  });

  ##############################################################################
  # Existing packages needing fixes that exist nowhere upstream
  ##############################################################################

  # OxCaml's stdlib types prerr_endline as `string @ local -> unit` and `ignore`
  # is not local-polymorphic; patch the two spots in topfind.
  findlib = prev.findlib.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./patches/findlib-locality.patch ];
  });

  # OxCaml's -pack requires units (and the .cmi derived from their .mli) to be
  # compiled with -for-pack; upstream OCaml tolerates the mismatch. ocamlbuild's
  # Makefile only passed it on the native rule.
  ocamlbuild = prev.ocamlbuild.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./patches/ocamlbuild-forpack.patch ];
  });

  # ocaml-compiler-libs vendors the vanilla compiler-libs; in OxCaml
  # Cmo_format.cu_name is a Compilation_unit.t rather than `Compunit of string`.
  ocaml-compiler-libs = prev.ocaml-compiler-libs.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./patches/ocaml-compiler-libs-cmo-format.patch ];
  });

  # yojson re-exports Buffer.add_string with a non-local .mli type; OxCaml infers
  # `@ local`, so the bindings need annotating.
  yojson = prev.yojson.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./patches/yojson-locality.patch ];
  });

  # Two unrelated problems. OxCaml unifies lwt's recv/send/recvfrom/sendto C
  # stubs with its locality-annotated Unix functions, hence the patch. And
  # lwt_libev_stubs.c has a `callback` parameter that collides with OxCaml's
  # CAML_DEPRECATED macro; oxopam never builds it because conf-libev is not in
  # the switch, so drop libev here too.
  lwt = prev.lwt.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./patches/lwt-locality.patch ];
    propagatedBuildInputs = lib.filter (p: (p.pname or "") != "libev") old.propagatedBuildInputs;
  });

  # Topkg.String re-exports String, which is @@ portable in OxCaml; the
  # implementation's copy is coerced to nonportable, so the signature must match.
  topkg = prev.topkg.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./patches/topkg-modes.patch ];
  });

  ##############################################################################
  # Test suites that OxCaml's mode checking rejects
  ##############################################################################

  # These test suites partially apply Random.State.int and similar, which
  # local_ mode rejects. The libraries themselves build and link.
  qcheck-core = prev.qcheck-core.overrideAttrs { doCheck = false; };
  qcheck-ounit = prev.qcheck-ounit.overrideAttrs { doCheck = false; };
  qcheck = prev.qcheck.overrideAttrs { doCheck = false; };

  ##############################################################################
  # Misc
  ##############################################################################

  # nixpkgs picks merlin by exact OCaml version string; "5.2.0+ox" is not a key
  # in that table, so the attribute would throw during evaluation. Select the
  # 5.2-compatible release to keep the scope evaluatable, but merlin does not
  # actually build: OxCaml's mode system rejects merlin's own sources
  # (msupport_parsing.ml infers `exn -> 'a @ unique portable`, sexp.ml partially
  # applies Buffer.add_string in a tail call, misc.ml trips the
  # unsafe_multidomain alert on Printexc.register_printer).
  merlin = (prev.merlin.override { version = "5.3-502"; }).overrideAttrs (old: {
    meta = old.meta // {
      broken = true;
    };
  });
}
