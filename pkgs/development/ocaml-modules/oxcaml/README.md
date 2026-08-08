# OxCaml package scope

`pkgs.oxcamlPackages` (`ocaml-ng.ocamlPackages_oxcaml`) is a `mkOcamlPackages`
scope built against [OxCaml](https://oxcaml.org), Jane Street's
performance-focused fork of OCaml.

OxCaml extends OCaml with a mode system — locality, portability, uniqueness,
contention — and with an extended Parsetree. Consequently a fair number of
libraries that build fine on stock OCaml do not build here unmodified, and some
do not build at all.

## Scope of support

**Only the packages listed below are known to build.** The scope inherits ~1000
package definitions from `pkgs/top-level/ocaml-packages.nix`, and the vast
majority of them have never been built against OxCaml. Do not assume an
arbitrary `oxcamlPackages.<foo>` works; if you try one and it builds, please add
it to this list.

The set is deliberately not `recurseIntoAttrs`, so Hydra does not walk it and
these packages are **not** in the binary cache. The compiler itself
(`pkgs.oxcaml`) is a top-level attribute and is cached.

### Known to build

    dune_3  findlib  ocamlbuild  ocaml-compiler-libs
    alcotest  lwt  qcheck  qcheck-core  qcheck-ounit
    re  topkg  uutf  yojson  zarith

### Known broken

- `merlin` — OxCaml's mode system rejects merlin's own sources. The attribute is
  kept (with a pinned version, since `5.2.0+ox` is not a key in merlin's version
  table) only so the scope evaluates; it is marked `meta.broken`.

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

The handful of fixes that exist nowhere upstream are vendored in `./patches`.

## Adding a package

1. Check whether oxopam has a recipe for it. If so, reuse its patch set — add the
   package's `patches:` list to `./patch-sets.nix` and reference it with
   `patchesFor`.
2. Prefer `prev.<pkg>.overrideAttrs` over redefining the derivation, so nixpkgs'
   own packaging keeps applying.
3. Anything a package's dune `(libraries ...)` mentions must be in
   `propagatedBuildInputs`, not `buildInputs`: dune records the full library
   closure in each installed `dune-package`, so a missing propagation surfaces as
   `Error: Library "X" not found` in a *downstream* package.
4. If you disable a test suite, say which test fails and why in a comment.
