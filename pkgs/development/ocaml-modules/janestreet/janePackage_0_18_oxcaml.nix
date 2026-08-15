# Builder for the Jane Street libraries as packaged for OxCaml.
#
# Same shape as janePackage_0_17.nix, with one addition: `rev`. Jane Street has
# not released v0.18 (the latest tag is v0.17.3), so these packages are pinned to
# commits on the upstream `oxcaml` branches rather than to `v${version}` tags.
# With `rev` unset the behaviour is identical to the other janePackage helpers.
{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  # All the pinned revisions share a commit date of 2026-07-10 and correspond to
  # oxcaml/opam-repository's v0.18~preview.130.106+341 package set. That opam
  # version string cannot be used verbatim: `~` is not legal in a store path.
  defaultVersion ? "0.18.0-unstable-2026-07-10",
}:

{
  pname,
  version ? defaultVersion,
  rev ? "v${version}",
  hash,
  minimalOCamlVersion ? "5.1",
  doCheck ? true,
  patches ? [ ],
  buildInputs ? [ ],
  propagatedBuildInputs ? [ ],
  ...
}@args:

buildDunePackage (
  args
  // {
    inherit
      version
      patches
      buildInputs
      propagatedBuildInputs
      ;

    inherit minimalOCamlVersion;

    src = fetchFromGitHub {
      owner = "janestreet";
      repo = pname;
      inherit rev;
      sha256 = hash;
    };

    inherit doCheck;

    meta = {
      license = lib.licenses.mit;
      homepage = "https://github.com/janestreet/${pname}";
    }
    // args.meta;
  }
)
