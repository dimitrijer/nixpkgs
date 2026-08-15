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
  makeWrapper,
}:

final: prev:

let
  oxOpam = import ./opam-repository.nix { inherit fetchFromGitHub; };
  inherit (oxOpam) patchesFor;
  patchSets = import ./patch-sets.nix;

  # Packages OxCaml breaks -- built here, failed, and verified to build on a
  # stock 5.2. Marked broken rather than left to warn: a warning says "nobody
  # has tried this", and for these somebody has.
  brokenByOxcaml = import ./broken.nix;

  # Libraries that build but whose tests do not, with the reason for each.
  noCheck = import ./no-check.nix;

  # The v0.18 Jane Street set, pinned to the upstream `oxcaml` branches. `self`
  # is the final scope so the module's `with self;` cross-references resolve.
  janeStreet = lib.recurseIntoAttrs (
    import ../janestreet/0.18-oxcaml.nix {
      self = final;
      inherit lib patchesFor;
    }
  );

  # OxCaml's Parsetree carries ~47 constructors beyond any stock OCaml release
  # (unboxed literals, jkind annotations, quote/borrow expressions, ...).
  # ppxlib's astlib redefines the Parsetree types with exact-equality
  # constraints, so no unpatched ppxlib can build against it. oxopam ships
  # ppxlib_ast.0.33.0+ox2 with a custom ast_999.ml mirroring OxCaml's Parsetree
  # plus the wiring patches; ppxlib.0.33.0+ox2 uses the identical patch set.
  #
  # Unlike nixpkgs' single ppxlib derivation, ppxlib_ast is built separately and
  # first. Both ppxlib and ppxlib_jane link against it, and the split is what
  # keeps the graph acyclic: the v0.18 ppxlib_jane propagates ppxlib_ast, where
  # the v0.17 one propagates ppxlib and would close a loop through ppxlib.
  ppxlibSrc = fetchFromGitHub {
    owner = "ocaml-ppx";
    repo = "ppxlib";
    rev = "1f788de67fd04d7e608376ac26ee57deeeb93fdd";
    hash = "sha256-gryEqVTmTMnTYb1bPlGdWhCpoDUyrs4O3zEYkaau2rw=";
  };

  jsOfOCamlSrc = fetchFromGitHub {
    owner = "ocsigen";
    repo = "js_of_ocaml";
    rev = "930c6b7f4126eff48cef94d5dd30d1078821eb62";
    hash = "sha256-eVMboI/olC181tIAI3v5dpUpQXmGrYbKCZoQ9+IAu3Y=";
  };

  # ocaml-lsp links merlin's libraries directly, so it inherits merlin's
  # constraint: it has to be built against the frontend the compiler agrees
  # with. OxCaml maintains the port as a fork rather than a patch set, which
  # oxopam packages as ocaml-lsp-server.1.19.0+ox2.
  #
  # That recipe's url is a branch ref, so `opam install ocaml-lsp-server` on an
  # OxCaml switch resolves to whatever 5.2.0minus-39 points at -- not to the
  # x-commit-hash recorded alongside it, which is 82 commits stale and predates
  # the fork's move onto Async. Pin the branch head, which is what that install
  # actually gives you. It has no tag.
  #
  # 5.2.0minus-39 is the fork's only current branch, and the compiler here is
  # minus-40, because merlin cannot be built from the minus-39 tree at all --
  # see pkgs/by-name/ox/oxcaml/package.nix. The two Typedtree constructors that
  # changed in between are patched below; there is nothing else to reconcile.
  ocamlLspSrc = fetchFromGitHub {
    owner = "oxcaml";
    repo = "ocaml-lsp";
    rev = "1b5b095afb2cd27dd624b4030625ae92bf88bc79"; # head of 5.2.0minus-39
    hash = "sha256-yT3AV9mwTiwLWhmHgUcEAY1LrEhxvJHNgItWtBsHHjk=";
  };

  ocamlLspVersion = "1.19.0+ox2";

  # ocamlformat vendors its own copy of the OCaml grammar rather than calling
  # the compiler's parser (vendor/parser-extended, vendor/parser-standard), so
  # a released ocamlformat cannot read OxCaml source at all: it has no `local_`,
  # no labelled tuples, no kind annotations, no unboxed literals. Patching one
  # into building would produce a binary that then rejects every file. OxCaml
  # therefore maintains a fork, which oxopam packages as ocamlformat.0.26.2+ox2
  # with an empty patch list and a branch for a url.
  #
  # Unlike merlin and ocaml-lsp, this one is *not* coupled to the compiler pin.
  # ocamlformat never opens a .cmi and never looks at a Typedtree -- it is a
  # source-to-source tool -- so the minus-39 in the branch name tracks the
  # syntax it accepts, not a release's internals. It builds and formats
  # correctly against the minus-40 compiler pinned here, and the fork has no
  # minus-40 branch to move to.
  ocamlFormatSrc = fetchFromGitHub {
    owner = "oxcaml";
    repo = "ocamlformat";
    rev = "3aa293b7896b91cef70d4a0eaae31d7eec3184d8"; # head of with-extensions-minus-39
    hash = "sha256-cazRbX5rmLGkBrdhTltqXUIQtbNNo/jRuhoUPRwPhvY=";
  };

  ocamlFormatVersion = "0.26.2+ox2";

  # Only ocaml-lsp-server reads the Typedtree, but all three packages are built
  # from this one tree, and dune builds the whole workspace, so the patch has to
  # be applied uniformly or the jsonrpc/lsp builds fail on the unpatched files.
  ocamlLspPatches = [ ./patches/ocaml-lsp-minus40-typedtree.patch ];

  # ocaml-lsp is a yojson 2 consumer: Jsonrpc.Json.t spells out the 2.x
  # Safe.t, tags `Tuple and `Variant included, and yojson 3 dropped both, so
  # the scope's default 3.0.0 will not typecheck. The v0.18 ppx_yojson_conv_lib
  # is capped below 3.0.0 for the same reason and already propagates this.
  yojson2 = final.yojson_2;

  # merlin, merlin-lib, dot-merlin-reader and ocaml-index all come out of
  # external/merlin in the compiler's own tree -- see the section below for why
  # no released merlin can be used instead. oxopam packages the four the same
  # way, from the same directory and the same patch, as *.5.2.1-502+ox2.
  mkMerlinPackage =
    args:
    final.buildDunePackage (
      {
        version = "5.2.1-502+ox2";

        # The compiler derivation has already fetched this; taking merlin from
        # anywhere else would risk the two disagreeing about the object file
        # format, which postPatch below checks that they do not.
        src = final.ocaml.src;
        sourceRoot = "source/external/merlin";

        # Two hunks: eta-expand the `ref raise` that OxCaml's mode system infers
        # as `exn -> 'a @ unique portable`, and drop src/kernel/dune's copy rule
        # for ../runtime/float32.c, which resolves only inside the compiler
        # tree. The paths are a/external/merlin/..., but sourceRoot has already
        # moved us there, hence -p3.
        patches = patchesFor "merlin/merlin.5.2.1-502+ox2" patchSets.merlin;
        patchFlags = [ "-p3" ];

        postPatch = ''
          # The compiler tree has a dune-project of its own at the root, and
          # dune resolves the workspace root by climbing to the outermost one.
          # Left alone it walks out of external/merlin and tries to build the
          # compiler; a dune-workspace stops it here.
          echo '(lang dune 3.0)' > dune-workspace

          # The magic number is the whole reason these packages are built from
          # the compiler's own source rather than from a release, so check it
          # rather than trust it: external/merlin has historically lagged the
          # compiler by a release within a single commit, which produces a
          # merlin that builds cleanly and then rejects every .cmi it reads.
          merlinMagic=$(sed -n 's/^let cmi_magic_number = "\(.*\)"$/\1/p' \
            src/ocaml/utils/config.ml)
          compilerMagic=$(head -c ''${#merlinMagic} \
            ${final.ocaml}/lib/ocaml/stdlib.cmi)
          if [ "$merlinMagic" != "$compilerMagic" ]; then
            echo "merlin expects $merlinMagic but the compiler emits" \
              "$compilerMagic; external/merlin is out of sync with the" \
              "oxcaml pin in pkgs/by-name/ox/oxcaml/package.nix" >&2
            exit 1
          fi

          # A matching magic number is necessary but nowhere near sufficient.
          # OxCaml bumps it once per minus-release, while the types marshalled
          # into a .cmi change whenever a PR touches them, and merlin's copy of
          # typing/ is re-synced by hand only in occasional "Merlin for
          # <release>" commits. Between the two, merlin unmarshals a .cmi it
          # believes it understands into differently shaped blocks -- reading a
          # nullary constructor as a pointer -- and segfaults on the first
          # cross-module record or variant pattern. That is not a hypothetical:
          # it is the state of every commit on the 5.2.0minus-39 line.
          #
          # So compare the declarations themselves. Only the types reachable
          # from a .cmi matter; merlin's copy legitimately differs elsewhere.
          # Normalise one declaration to a comment-free, whitespace-collapsed
          # block so that reindentation and comment edits do not read as drift.
          extract='
            /^(type|and)[ \t]/ { inblock = ($2 == NAME) }
            /^(let|val|exception|module|open|include|external)[ \t]/ { inblock = 0 }
            inblock {
              line = $0
              gsub(/\(\*[^*]*\*\)/, "", line)
              gsub(/^[ \t]+|[ \t]+$/, "", line)
              gsub(/[ \t]+/, " ", line)
              if (line != "") print line
            }'
          drift=
          for name in type_declaration type_kind record_representation \
            record_unboxed_product_representation variant_representation \
            constructor_representation cstr_layout mixed_product_shape \
            mixed_block_element label_declaration constructor_declaration \
            constructor_argument value_description signature_item \
            extension_constructor; do
            if ! diff -q \
              <(awk -v NAME="$name" "$extract" ../../typing/types.ml) \
              <(awk -v NAME="$name" "$extract" src/ocaml/typing/types.ml) \
              > /dev/null; then
              drift="$drift $name"
            fi
          done
          if [ -n "$drift" ]; then
            echo "external/merlin and typing/ disagree on the .cmi" \
              "representation of:$drift" >&2
            echo "Both are at $merlinMagic, so merlin would load .cmi files" \
              "it cannot correctly decode and crash. Move the oxcaml pin in" \
              "pkgs/by-name/ox/oxcaml/package.nix to a commit where the two" \
              "agree -- usually a 'Merlin for <release>' commit." >&2
            exit 1
          fi
        '';

        # The cram tests want conf-jq, and dune -p would skip them anyway.
        doCheck = false;
      }
      // args
      // {
        meta = {
          homepage = "https://github.com/ocaml/merlin";
          license = lib.licenses.mit;
          maintainers = [ ];
        }
        // (args.meta or { });
      }
    );
in

{
  ##############################################################################
  # Packages replaced wholesale by their oxopam recipe
  ##############################################################################

  ppxlib_ast = final.buildDunePackage {
    pname = "ppxlib_ast";
    version = "0.33.0+ox2";
    src = ppxlibSrc;
    patches = patchesFor "ppxlib_ast/ppxlib_ast.0.33.0+ox2" patchSets.ppxlib_ast;
    # dune records the full library closure in each installed dune-package, so
    # everything named in (libraries ...) has to be propagated or downstream
    # packages fail to resolve it.
    propagatedBuildInputs = [
      final.ocaml-compiler-libs
      final.ppx_derivers
      final.sexplib0
      final.stdlib-shims
    ];
  };

  ppxlib = final.buildDunePackage {
    pname = "ppxlib";
    version = "0.33.0+ox2";
    src = ppxlibSrc;
    patches = patchesFor "ppxlib/ppxlib.0.33.0+ox2" patchSets.ppxlib;
    propagatedBuildInputs = [
      final.ppxlib_ast
      # oxopam's dune.patch links ppxlib_jane into ppxlib's src/, gen/ and
      # traverse/ directories, so ppxlib_jane must build first. It only needs
      # ppxlib_ast, so this stays acyclic.
      final.ppxlib_jane
      final.ocaml-compiler-libs
      final.ppx_derivers
      final.sexplib0
      final.stdlib-shims
    ];
  };

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

  # All three js_of_ocaml packages come from one commit with one patch set each;
  # only the position of dune.patch differs between them. virtual_dom (and so
  # bonsai_term) needs them, and the oxcaml-branched Jane Street stack was built
  # against these versions.
  js_of_ocaml-compiler = final.buildDunePackage {
    pname = "js_of_ocaml-compiler";
    version = "6.3.2+ox";
    src = jsOfOCamlSrc;
    patches = patchesFor "js_of_ocaml-compiler/js_of_ocaml-compiler.6.3.2+ox" patchSets.js_of_ocaml_compiler;
    nativeBuildInputs = [ final.menhir ];
    buildInputs = [
      final.cmdliner
      final.ppxlib
    ];
    propagatedBuildInputs = [
      final.menhirLib
      final.yojson
      final.findlib
      final.sedlex
    ];
  };

  js_of_ocaml = final.buildDunePackage {
    pname = "js_of_ocaml";
    version = "6.3.2+ox";
    src = jsOfOCamlSrc;
    patches = patchesFor "js_of_ocaml/js_of_ocaml.6.3.2+ox" patchSets.js_of_ocaml;
    buildInputs = [ final.ppxlib ];
    propagatedBuildInputs = [ final.js_of_ocaml-compiler ];
  };

  js_of_ocaml-ppx = final.buildDunePackage {
    pname = "js_of_ocaml-ppx";
    version = "6.3.2+ox";
    src = jsOfOCamlSrc;
    patches = patchesFor "js_of_ocaml-ppx/js_of_ocaml-ppx.6.3.2+ox" patchSets.js_of_ocaml_ppx;
    # js_of_ocaml is a ppx_runtime_dep here, so it has to be propagated or
    # bonsai's effects library fails to resolve it.
    propagatedBuildInputs = [
      final.js_of_ocaml
      final.ppxlib
    ];
  };

  gen_js_api = final.buildDunePackage {
    pname = "gen_js_api";
    version = "1.1.2+ox";
    src = fetchFromGitHub {
      owner = "LexiFi";
      repo = "gen_js_api";
      rev = "2c72798f19cdff89c72b595371cdf8010d457f6a"; # v1.1.2
      hash = "sha256-tplbnQ/1dzZq8m/ibMAkGqY8RHQRmBPHOwh0dGuZCJM=";
    };
    patches = patchesFor "gen_js_api/gen_js_api.1.1.2+ox" patchSets.gen_js_api;
    doCheck = false; # the expect tests encode pre-patch output
    propagatedBuildInputs = [
      final.ojs
      final.ppxlib
    ];
    # nixpkgs' ojs inherits gen_js_api.meta, so this has to be a full attrset.
    meta = {
      description = "Easy OCaml bindings for JavaScript libraries";
      homepage = "https://github.com/LexiFi/gen_js_api";
      license = lib.licenses.mit;
      maintainers = [ ];
    };
  };

  ##############################################################################
  # Existing packages that only need the oxopam patches applied
  ##############################################################################

  # ppx_sedlex reads the Parsetree directly; OxCaml changed Ppat_tuple (it now
  # carries a closed flag and labelled tuples) and Exp.fun_.
  sedlex = prev.sedlex.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ patchesFor "sedlex/sedlex.3.7+ox" patchSets.sedlex;
  });

  # Jane Street's notty_async needs Tmachine.set_mouse, dynamic mouse reporting
  # and hover events, none of which are in the release tarball nixpkgs builds.
  # oxopam patches the git revision below, which already uses Base.
  notty-community = prev.notty-community.overrideAttrs (old: {
    src = fetchFromGitHub {
      owner = "ocaml-community";
      repo = "notty-community";
      rev = "f9f3621ce566a682ba0cddf4930a3932a4b74652";
      hash = "sha256-bvtDJxga0G30erHC7fmaQkMStX0HXygkKWHG9sFVq8M=";
    };
    patches = patchesFor "notty-community/notty-community.0.2.4+ox2" (
      # The remaining patch does not apply against this revision; its intent is
      # already covered by the mouse-reporting patches above it.
      lib.filter (
        p: p != "notty-defensively-ignore-corrupted-x10-vscode-mouse-codes.patch"
      ) patchSets.notty_community
    );
    propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [
      final.base
      final.portable
      final.portable_lockfree_htbl
      final.ppx_jane
    ];
  });

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

  # cmd_latex.ml partially applies Buffer.add_string, which OxCaml types as
  # `Buffer.t @ local -> string @ local -> unit`. Needed by ocaml-lsp, for
  # rendering markdown in hovers.
  cmarkit = prev.cmarkit.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ patchesFor "cmarkit/cmarkit.0.3.0+ox" patchSets.cmarkit;
  });

  # OxCaml types Stdlib.prerr_endline as `string @ local -> unit`, and `ignore`
  # is not local-polymorphic, so topfind's `if real_toploop then prerr_endline
  # else ignore` has no common type. oxopam eta-expands both branches.
  findlib = prev.findlib.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ patchesFor "ocamlfind/ocamlfind.1.9.8+ox" patchSets.ocamlfind;
  });

  # OxCaml's -pack requires units (and the .cmi derived from their .mli) to be
  # compiled with -for-pack; upstream OCaml tolerates the mismatch, and
  # ocamlbuild's Makefile only passed it on the native rule. oxopam splits the
  # generic %.cmo/%.cmi rules per directory so only src/ gets -for-pack, and
  # additionally propagates for-pack tags from .cmx to .ml/.mli in
  # configuration.ml, which the rules alone do not cover.
  ocamlbuild = prev.ocamlbuild.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ patchesFor "ocamlbuild/ocamlbuild.0.16.1+ox" patchSets.ocamlbuild;
  });

  # ocaml-compiler-libs vendors the vanilla compiler-libs; in OxCaml
  # Cmo_format.cu_name is a Compilation_unit.t rather than `Compunit of string`.
  ocaml-compiler-libs = prev.ocaml-compiler-libs.overrideAttrs (old: {
    patches =
      (old.patches or [ ])
      ++ patchesFor "ocaml-compiler-libs/ocaml-compiler-libs.v0.17.0+ox" patchSets.ocaml_compiler_libs;
  });

  # Two unrelated problems. `if Sys.win32 then Unix.recv else stub_recv` forces
  # the two branches to unify, and OxCaml's Unix.recv takes `bytes @ local`
  # where the C stub is an ordinary external; oxopam eta-expands the four call
  # sites so neither branch has to move. (Annotating the externals themselves
  # would work too, but those declarations describe the C FFI boundary and
  # should keep saying what the stubs actually do.) And lwt_libev_stubs.c has a
  # `callback` parameter that collides with OxCaml's CAML_DEPRECATED macro;
  # oxopam never builds it because conf-libev is not in the switch, so drop
  # libev here too.
  #
  # This scope gets lwt 5.9.1 -- nixpkgs picks lwt by compiler version, so it is
  # *not* the 6.1.2 the default scope gets -- which makes 5.9.2+ox the matching
  # recipe; its single patch applies at an offset of 5 lines. The 6.0.0+ox
  # recipe carries the same fix plus ppx_lwt hunks for the OxCaml Parsetree,
  # which neither apply to 5.9.1 nor matter here, as ppx_lwt is not built.
  lwt = prev.lwt.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ patchesFor "lwt/lwt.5.9.2+ox" patchSets.lwt;
    propagatedBuildInputs = lib.filter (p: (p.pname or "") != "libev") old.propagatedBuildInputs;
  });

  # Topkg.String re-exports String, whose trim and uppercase_ascii are
  # @@ portable in OxCaml, over an implementation that is not. oxopam annotates
  # the two in topkg_string.mli. The recipe is for 1.1.1 and this is 1.1.0, but
  # the .mli is unchanged between them and the patch applies exactly.
  topkg = prev.topkg.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ patchesFor "topkg/topkg.1.1.1+ox" patchSets.topkg;
  });

  ##############################################################################
  # The chokepoints
  #
  # These few packages sit under most of the rest of the scope: the triage in
  # maintainers/scripts/oxcaml measures ppx_deriving at 117 blocked dependents,
  # ctypes at 64, mdx at 39, lwt_ppx at 26 and extlib at 12. Unblocking them is
  # worth far more than their count suggests, and oxopam already has a recipe
  # for every one -- so none of this is hand-written.
  ##############################################################################

  # Partial applications of Bigarray.kind that OxCaml infers as local, plus the
  # unsafe_multidomain alert on Printexc.register_printer.
  ctypes = prev.ctypes.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ patchesFor "ctypes/ctypes.0.24.0+ox" patchSets.ctypes;
  });

  # Patch the definition, not the `extlib` alias. ocaml-packages.nix has
  # `extlib = extlib-1-7-9`, and `overrideScope` resolves an overlay's `prev`
  # against the *final* scope, so the alias follows whatever `extlib-1-7-9`
  # ends up being. Overriding the alias instead leaves two different
  # derivations under two names, and the alias silently inherits any meta the
  # definition carries.
  extlib-1-7-9 = prev.extlib-1-7-9.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ patchesFor "extlib/extlib.1.8.0+ox" patchSets.extlib;
  });

  ##############################################################################
  # Existing packages needing fixes that exist nowhere upstream
  ##############################################################################

  # yojson re-exports Buffer.add_string with a non-local .mli type; OxCaml infers
  # `@ local`, so the bindings need eta-expanding.
  #
  # oxopam has this fix, but only as yojson.2.2.2+ox, and its hunk does not
  # apply to the 3.0.0 this scope defaults to. This patch is that change
  # forward-ported; the three lines are identical in both releases, so it also
  # applies to yojson_2 (2.2.2), which inherits this override and is what
  # ocaml-lsp links.
  yojson = prev.yojson.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./patches/yojson-locality.patch ];
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
  # Editor tooling
  ##############################################################################

  # No released merlin works against OxCaml, and none can be made to.
  #
  # merlin vendors a copy of the OCaml frontend -- src/ocaml/{parsing,typing,
  # utils,driver} -- pinned to one compiler version, and src/ocaml/typing/
  # cmi_format.ml refuses any .cmi whose magic number is not the one that copy
  # was built for. merlin 5.3-502, the newest release on the 502 line, expects
  # Caml1999I034; OxCaml emits Caml1999I579. So a merlin patched into building
  # here would still reject every artifact the compiler produces, and later
  # merlin releases only move further away: 5.8.1 exists as -505 and -506, for
  # OCaml 5.5 and 5.6. There is no OxCaml branch upstream.
  #
  # What OxCaml does instead is carry its own merlin at external/merlin, in
  # sync with the compiler's object file format, and that is what its opam
  # repository ships as merlin.5.2.1-502+ox2 -- the merlin you get from the
  # install instructions at https://oxcaml.org/get-oxcaml/. These four packages
  # are that same tree, so they track the compiler pin automatically.
  merlin-lib = mkMerlinPackage {
    pname = "merlin-lib";

    propagatedBuildInputs = [ final.csexp ];
    buildInputs = [
      final.menhirLib
      final.menhirSdk
    ];
    nativeBuildInputs = [ final.menhir ];

    meta.description = "Merlin's libraries";
  };

  dot-merlin-reader = mkMerlinPackage {
    pname = "dot-merlin-reader";
    buildInputs = [
      final.merlin-lib
      final.findlib
    ];
    meta = {
      description = "Reads config files for merlin";
      mainProgram = "dot-merlin-reader";
    };
  };

  # Not packaged in nixpkgs outside this scope. merlin's opam file marks it
  # `post`, so it is optional to build against but wanted at runtime: it is
  # what backs project-wide occurrences.
  ocaml-index = mkMerlinPackage {
    pname = "ocaml-index";
    # Versioned independently of the merlin packages, as it is upstream.
    version = "1.1+ox2";
    buildInputs = [
      final.merlin-lib
      final.yojson
    ];
    meta = {
      description = "Indexes value usages from cmt files";
      mainProgram = "ocaml-index";
    };
  };

  merlin = mkMerlinPackage {
    pname = "merlin";
    buildInputs = [
      final.merlin-lib
      final.dot-merlin-reader
      final.yojson
    ];
    nativeBuildInputs = [ final.menhir ];

    # Deliberately no equivalent of merlin's fix-paths2.patch. OxCaml's
    # mconfig_dot.ml already looks for dot-merlin-reader in
    # $DOT_MERLIN_READER_EXE and then next to the merlin binary before falling
    # back to PATH, and always takes dune from PATH -- which is what you want,
    # since the dune that reads .merlin-conf has to be the one that wrote it.
    meta = {
      description = "Editor helper, provides completion, typing and source browsing in Vim and Emacs";
      mainProgram = "ocamlmerlin";
    };
  };

  # nixpkgs builds all three of these from one ocaml-lsp release tarball chosen
  # by OCaml version; "5.2.0+ox" lands on 1.21.0, which links the released
  # merlin-lib and so cannot work here. Take them from the fork instead.
  jsonrpc = final.buildDunePackage {
    pname = "jsonrpc";
    version = ocamlLspVersion;
    src = ocamlLspSrc;
    patches = ocamlLspPatches;

    propagatedBuildInputs = [ yojson2 ];

    meta = {
      description = "Jsonrpc protocol implementation in OCaml";
      homepage = "https://github.com/ocaml/ocaml-lsp";
      license = lib.licenses.isc;
      maintainers = [ ];
    };
  };

  lsp = final.buildDunePackage {
    pname = "lsp";
    version = ocamlLspVersion;
    src = ocamlLspSrc;
    patches = ocamlLspPatches;

    buildInputs = [ final.ppx_yojson_conv ];

    propagatedBuildInputs = [
      final.base
      final.jsonrpc
      final.ppx_yojson_conv_lib
      final.uutf
      yojson2
    ];

    meta = final.jsonrpc.meta // {
      description = "LSP protocol implementation in OCaml";
    };
  };

  ocaml-lsp = final.buildDunePackage {
    pname = "ocaml-lsp-server";
    version = ocamlLspVersion;
    src = ocamlLspSrc;
    patches = ocamlLspPatches;

    # lev and lev_fiber are private libraries under vendor/, libev C sources
    # included, and fiber_async, lev_fiber_async, lsp_fiber and jsonrpc_fiber
    # are private libraries of this same workspace, so none of them appears
    # here. Everything else is what ocaml-lsp-server/src/dune links.
    buildInputs = [
      final.astring
      final.async
      final.async_log
      final.base
      final.camlp-streams
      final.chrome-trace
      final.cmarkit
      final.core
      final.core_unix
      final.csexp
      final.dune-build-info
      final.dune-rpc
      final.dyn
      final.fiber
      final.lsp
      final.merlin-lib
      final.ocamlc-loc
      final.ocamlformat-rpc-lib
      final.odoc-parser
      final.ordering
      final.ppx_jane
      final.ppx_yojson_conv
      final.ppx_yojson_conv_lib
      final.ppxlib
      final.re
      final.re2
      final.spawn
      final.stdune
      final.xdg
      yojson2
    ];

    nativeBuildInputs = [ makeWrapper ];

    # ocamllsp spawns dot-merlin-reader for non-dune projects. It looks in
    # $DOT_MERLIN_READER_EXE first, and nothing else puts the binary in scope
    # for an editor started outside the dev shell.
    postInstall = ''
      wrapProgram $out/bin/ocamllsp \
        --set-default DOT_MERLIN_READER_EXE \
          ${final.dot-merlin-reader}/bin/dot-merlin-reader
    '';

    meta = final.jsonrpc.meta // {
      description = "OCaml Language Server Protocol implementation";
      mainProgram = "ocamllsp";
    };
  };

  # nixpkgs' ocamlformat is 0.29.0, which does not build here at all: its own
  # sources trip OxCaml's mode checking (Array.binary_search returning a local
  # in lib/Source.ml) and the v0.18 base changed the comparator record it reads
  # in lib/Non_overlapping_interval_tree.ml. Both are ordinary porting
  # problems -- and fixing them would still leave a binary whose grammar cannot
  # parse OxCaml. Take the fork instead; see the note by ocamlFormatSrc.
  #
  # ocamlformat-rpc-lib is deliberately *not* overridden. It carries no parser,
  # builds unmodified, and ocaml-lsp already links the scope's copy.
  ocamlformat-lib = final.buildDunePackage {
    pname = "ocamlformat-lib";
    version = ocamlFormatVersion;
    src = ocamlFormatSrc;

    nativeBuildInputs = [ final.menhir ];

    propagatedBuildInputs = with final; [
      astring
      base
      camlp-streams
      cmdliner
      dune-build-info
      either
      fix
      fpath
      menhirLib
      menhirSdk
      ocaml-version
      ocp-indent
      ppx_sexp_conv
      sexplib0
      stdio
      uucp
      uuseg
    ];

    # The test suite is a corpus of stock-OCaml sources compared against
    # expected output; this grammar formats several of them differently.
    doCheck = false;

    meta = {
      homepage = "https://github.com/ocaml-ppx/ocamlformat";
      description = "Auto-formatter for OCaml code (library)";
      license = lib.licenses.mit;
      maintainers = [ ];
    };
  };

  ocamlformat = final.buildDunePackage {
    pname = "ocamlformat";
    version = ocamlFormatVersion;
    src = ocamlFormatSrc;

    buildInputs = with final; [
      cmdliner
      csexp
      ocamlformat-lib
      re
    ];

    doCheck = false;

    meta = final.ocamlformat-lib.meta // {
      description = "Auto-formatter for OCaml code";
      mainProgram = "ocamlformat";
    };
  };

  ##############################################################################
  # Jane Street
  ##############################################################################

  janePackage = final.callPackage ../janestreet/janePackage_0_18_oxcaml.nix { };
  inherit janeStreet;
}
# mkOcamlPackages has already applied liftJaneStreet, which lifts the v0.17 set
# into the scope. Re-applying it would be a no-op (`super` wins there), so the
# v0.18 names are merged in here instead, where this overlay's layer wins.
// janeStreet
// lib.mapAttrs (name: _reason: prev.${name}.overrideAttrs { doCheck = false; }) noCheck
// lib.mapAttrs (
  name: failureClass:
  prev.${name}.overrideAttrs (old: {
    meta = (old.meta or { }) // {
      broken = true;
    };
  })
) brokenByOxcaml
