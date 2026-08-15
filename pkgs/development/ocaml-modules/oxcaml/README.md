# OxCaml package scope

`pkgs.oxcamlPackages` (`ocaml-ng.ocamlPackages_oxcaml`) is a `mkOcamlPackages`
scope built against [OxCaml](https://oxcaml.org), Jane Street's
performance-focused fork of OCaml.

OxCaml extends OCaml with a mode system — locality, portability, uniqueness,
contention — and with an extended Parsetree. Consequently a fair number of
libraries that build fine on stock OCaml do not build here unmodified, and some
do not build at all.

## Scope of support

**Only the packages listed below are known to build.** The scope inherits ~1250
package definitions from `pkgs/top-level/ocaml-packages.nix`, and the vast
majority of them have never been built against OxCaml.

This is enforced, not just documented. The list below is mirrored in
[`./supported.nix`](./supported.nix), and anything outside it warns when you
reach for it:

    $ nix-build -A oxcamlPackages.cohttp
    evaluation warning: oxcamlPackages.cohttp has never been built against
    OxCaml and may fail to build or misbehave. [...]

The build still proceeds — the warning marks unported packages without putting a
wall in front of experimenting with them. If you try one and it works, add it to
`./supported.nix` *and* to the list below; the two are kept in sync by an
assertion, so a name in one and not the other is an eval error.

`oxcamlPackages.untested` is the same scope with nothing wrapped, for when you
have decided you want an unported package and would rather not hear about it
again.

Four things are deliberately **not** guarded, because a wrapper on the finished
scope cannot reach inside it: `callPackage` and `newScope` fill their arguments
from the unwrapped scope, `overrideScope` rebuilds from the original definitions,
and `janeStreet` is left whole (see below). Use them knowing the warning will not
fire.

The set is deliberately not `recurseIntoAttrs`, so Hydra does not walk it and
these packages are **not** in the binary cache. The compiler itself
(`pkgs.oxcaml`) is a top-level attribute and is cached.

### Known to build

Toolchain and third-party libraries:

    dune_3  findlib  ocamlbuild  ocaml-compiler-libs
    alcotest  gen_js_api  js_of_ocaml  js_of_ocaml-compiler  js_of_ocaml-ppx
    lwt  notty-community  ppxlib  ppxlib_ast  qcheck  qcheck-core
    qcheck-ounit  re  sedlex  topkg  uutf  yojson  zarith

Editor tooling:

    dot-merlin-reader  jsonrpc  lsp  merlin  merlin-lib  ocaml-index
    ocaml-lsp  ocamlformat  ocamlformat-lib

and the pieces of ocaml-lsp's closure the scope did not already carry:

    cmarkit  jane_rope  ppx_yojson_conv  ppx_yojson_conv_lib  re2
    regex_parser_intf

Jane Street (`oxcamlPackages.janeStreet`, also lifted to the top of the scope):

    async  base  bignum  bonsai  bonsai_term  bonsai_term_test  core
    core_kernel  core_unix  notty_async  ppx_jane  ppxlib_jane  spawn
    textutils  textutils_kernel  virtual_dom

The rest of the 141-package Jane Street set is defined in
`../janestreet/0.18-oxcaml.nix` and is expected to work — it is the same set the
upstream `oxcaml` branches ship — but only the packages above have actually been
built here.

Alongside the hand-curated names above, **736 further packages** were found by
the triage harness in `maintainers/scripts/oxcaml`, which walks the scope
leaves-first and records what builds. They are not enumerated here — the list
lives in [`./supported.nix`](./supported.nix), which is the file the guard
actually reads, so there is nothing for this document to drift out of sync with.
Eighteen of them needed `doCheck = false`; the reason is on each entry in
`./no-check.nix`.

Because that set *is* one coherent upstream export, `oxcamlPackages.janeStreet`
is left unguarded as a whole: `janeStreet.<pkg>` reaches all 141 without
warning, while the lifted top-level names above are guarded like everything
else. So `oxcamlPackages.incr_map` warns and `oxcamlPackages.janeStreet.incr_map`
does not — the second spelling is the one that says "I know this is the
unverified part of a set that ships together".

### End-to-end

A `bonsai_term` application builds against this scope with no overlays:

```nix
mkShell {
  buildInputs = with oxcamlPackages; [
    ocaml dune_3 findlib bonsai bonsai_term core async core_unix ppx_jane
  ];
}
```

`ppx_bonsai` is not a separate package; it is the `bonsai.ppx_bonsai` sublibrary,
so depending on `bonsai` is enough to use `(preprocess (pps bonsai.ppx_bonsai))`.

### Editor tooling

`merlin` cannot be taken from a release here, and this is not a packaging
detail that can be worked around. merlin vendors a copy of the OCaml frontend
pinned to one compiler version, and `src/ocaml/typing/cmi_format.ml` rejects any
`.cmi` whose magic number differs from the one that copy was built for. merlin
5.3-502, the newest release on the 502 line, expects `Caml1999I034`; OxCaml
emits `Caml1999I579`. A merlin patched into building would still refuse every
artefact the compiler produces, and later releases only move further away —
5.8.1 exists as `-505` and `-506`, for OCaml 5.5 and 5.6.

OxCaml carries its own merlin at `external/merlin`, which is what its opam
repository ships as `merlin.5.2.1-502+ox2` and what the install instructions at
<https://oxcaml.org/get-oxcaml/> give you. `merlin`, `merlin-lib`,
`dot-merlin-reader` and `ocaml-index` are built from that directory in
`pkgs.oxcaml.src`, so they follow the compiler pin.

That copy is **not** kept in lockstep with the compiler it ships beside, and
this is the single sharpest edge in the whole scope. The magic number is bumped
once per minus-release; the types marshalled into a `.cmi` change whenever a PR
touches them; and `external/merlin`'s copy of `typing/` is re-synced by hand,
only in occasional "Merlin for `<release>`" commits. Between a change and its
sync, merlin and the compiler share a magic number while disagreeing about what
the bytes mean — merlin reads a nullary `Record_boxed` as a pointer and
**segfaults** on the first cross-module record pattern, with no diagnostic at
all.

Every commit on the `5.2.0minus-39` line has that defect, including the one
oxopam builds its merlin from. `merlin-lib` therefore checks more than the
magic number: `postPatch` compares the declarations of the types reachable from
a `.cmi` between `typing/types.ml` and merlin's copy, and fails the build if
they differ. If the compiler pin ever needs moving, move it to a commit that
passes that check — in practice a "Merlin for `<release>`" commit.

`ocaml-lsp` links merlin's libraries directly and pattern-matches its
Typedtree, so it tracks a single minus-release too, and OxCaml's fork currently
offers only a `5.2.0minus-39` branch — the line merlin cannot be built from.
The two are reconciled here by pinning the compiler to minus-40 and carrying
`patches/ocaml-lsp-minus40-typedtree.patch`, which is the whole of the delta:
`Tpat_record` went from two arguments to four, and `Texp_construct` from four
to five with a sorted argument list. Neither site uses the added information.

Note also that oxopam's recipe for `ocaml-lsp` names a *branch* rather than a
commit, so there is no stable revision to track; the pin here is that branch's
head.

`ocamlformat` comes from a fork too, for a different reason: it vendors its own
copy of the OCaml grammar instead of calling the compiler's parser, and that
grammar has no `local_`, no labelled tuples, no kind annotations and no unboxed
literals. The 0.29.0 nixpkgs selects also fails to build here — OxCaml's mode
checking rejects `lib/Source.ml`, and the v0.18 `base` changed the comparator
record `lib/Non_overlapping_interval_tree.ml` reads — but fixing that would only
produce a binary that then refuses to parse OxCaml source. `ocamlformat` and
`ocamlformat-lib` are built from `oxcaml/ocamlformat`, matching oxopam's
`ocamlformat.0.26.2+ox2`, whose patch list is empty because the fork *is* the
patch.

That fork is not tied to the compiler pin the way merlin and `ocaml-lsp` are:
ocamlformat never opens a `.cmi` and never inspects a Typedtree, so the
`minus-39` in its branch name describes the syntax it accepts, not a release's
internals. It builds and formats correctly against the minus-40 pin.

`ocamlformat-rpc-lib` is left alone — it carries no parser, builds unmodified,
and is what `ocaml-lsp` links.

Two consequences for users. The binary reports its version as `unknown`, so a
project `.ocamlformat` must not pin `version = ...` (or must set
`version-check = false`), and the version is 0.26.2 where the rest of nixpkgs
is on 0.29.0, so formatting differs from a stock switch.

## How the patches are sourced

Most OxCaml compatibility patches already exist in
[`oxcaml/opam-repository`](https://github.com/oxcaml/opam-repository) ("oxopam"),
which is the reference packaging for this toolchain. Rather than vendoring ~150
patch files, that repository is fetched once and pinned by commit in
`./opam-repository.nix`, and individual patches are referenced by path.

`./patch-sets.nix` lists the patch file names per package. It is **generated from
the opam files' `patches:` fields**, preserving their order, so the lists can be
regenerated and diffed mechanically rather than trusted as hand transcription.
The directory is never globbed: a glob would make these derivations depend on the
pin's contents in a way that cannot be reviewed.

Note that oxopam often carries several versions of a recipe, and the one to
reuse is the one matching the version *this scope* resolves to — which is not
always the version the default `ocamlPackages` gets. `lwt` is the live example:
the default scope is on 6.1.2, this one on 5.9.1, and oxopam has both a
`lwt.5.9.2+ox` and a `lwt.6.0.0+ox`. Only the former is the right reference.

Only three fixes exist nowhere upstream and are vendored:

    ./patches/yojson-locality.patch          oxopam has it only for yojson 2.2.2
    ./patches/ocaml-lsp-minus40-typedtree.patch   ports minus-39 -> minus-40
    ../janestreet/oxcaml-patches/bignum-local.patch

Each carries a header comment explaining why it is not simply an oxopam patch
path. Everything else comes from oxopam.

## Upstream state

Checked 2026-08-23. **Nothing in the OxCaml ecosystem had moved since these pins
were taken**, so none of the patches above could be dropped as fixed upstream:

* All 141 Jane Street pins in `../janestreet/0.18-oxcaml.nix` are unmoved: 140
  are still exactly the head of their upstream `oxcaml` branch, and `spawn`,
  which has none, is still at the v0.15.1 commit oxopam names. Jane Street
  pushes these branches as one batch export from its monorepo, so they move
  together or not at all; the last export is still the 2026-07-10 one.
* oxopam's `main` is still the pinned commit (last commit 2026-07-31). Its other
  branches — `dev`, `unified`, `5.2.0minus38` — are all *older*, not newer.
* `oxcaml/ocaml-lsp` still has only a `5.2.0minus-39` branch, at the pinned
  head, so `ocaml-lsp-minus40-typedtree.patch` is still load-bearing.
* `oxcaml/ocamlformat`'s `with-extensions-minus-39` is still the pinned head.
* nixpkgs master has no OxCaml packaging of its own, and none of the packages
  patched here have changed upstream since this branch was cut.

The compiler has a newer **5.4.0-ox** line (`5.4.0-ox1` … `5.4.0-ox5`), but it is
not a candidate: oxopam's newest Jane Street package set is the
`v0.18~preview.130.106+341` one pinned here, and every one of its opam files
carries `conflicts: "oxcaml-compiler" {>= "5.4.0-ox1"}`. There is no Jane Street
package set for 5.4.0 to move to. `5.2.0minus-40` remains the newest release the
Jane Street stack builds against.

Do not be misled by oxopam's `oxcaml-*` and `oxcaml-*-patches` package
namespaces. They are not an alternative package set; they are empty opam
bookkeeping guards (`.guard` / `.enabled`) that record whether the patched
variant of a package is installed in a switch.

## Adding a package

1. Check whether oxopam has a recipe for it, and pick the version of that recipe
   matching what this scope resolves to (see the note above about `lwt`). If so,
   reuse its patch set — add the package's `patches:` list to
   `./patch-sets.nix` and reference it with `patchesFor`. Prefer this even when
   a smaller hand-written patch would also build: oxopam's is the fix the rest
   of the toolchain is tested against, and it is frequently the more complete
   one. Vendor a patch only when no oxopam recipe matches the version here.
2. Prefer `prev.<pkg>.overrideAttrs` over redefining the derivation, so nixpkgs'
   own packaging keeps applying.
3. Anything a package's dune `(libraries ...)` mentions must be in
   `propagatedBuildInputs`, not `buildInputs`: dune records the full library
   closure in each installed `dune-package`, so a missing propagation surfaces as
   `Error: Library "X" not found` in a *downstream* package.
4. If you disable a test suite, say which test fails and why in a comment.
5. Once it builds, add its attribute name to `./supported.nix` and to the
   "Known to build" list above. Both, in the same commit: an entry in
   `supported.nix` that the scope does not have fails evaluation, which is what
   keeps that file from drifting into fiction.
