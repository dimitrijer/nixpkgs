# The oxcaml/opam-repository ("oxopam") carries the OxCaml compatibility patches
# for the third-party OCaml libraries the Jane Street stack depends on. Rather
# than vendoring ~150 patch files into nixpkgs, the repository is fetched once,
# pinned by commit, and individual patches are referenced by path.
#
# Patch file names are enumerated explicitly, in the order each package's opam
# `patches:` field applies them (see ./patch-sets.nix, which is generated from
# those opam files). The directory is deliberately never globbed: globbing would
# make the derivations depend on the pin's contents in a way that cannot be
# reviewed.
{ fetchFromGitHub }:

let
  src = fetchFromGitHub {
    owner = "oxcaml";
    repo = "opam-repository";
    rev = "d65f081024758576f7a848bbd369863e7f7c1e81";
    hash = "sha256-nK+9+cN8j0WFDndW1FEJfaDMruTzrxqL623Nd54dh7E=";
  };
in
{
  inherit src;

  # patchesFor "ppxlib/ppxlib.0.33.0+ox2" [ "dune.patch" ... ]
  patchesFor = dir: names: map (name: "${src}/packages/${dir}/files/${name}") names;
}
