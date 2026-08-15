# Dependency graph over the OxCaml scope, for ./oxcaml-triage.py.
#
# Same idea as ../haskell/dependencies.nix: read the inputs off each already
# evaluated derivation, so the graph costs an eval and nothing else -- no .drv
# realisation, no nix-store queries.
#
# Only the attributes named in `candidatesFile` are inspected. That file comes
# from the nix-eval-jobs pass, which is the only way to find out which
# attributes evaluate at all: a single-process sweep cannot do it, because
# builtins.tryEval does not catch the "attribute 'branch' missing" that camlp4
# raises, and one such attribute takes the whole evaluation down.
{
  candidatesFile,
}:

let
  pkgs = import ../../.. { };
  inherit (pkgs) lib;

  # `untested` is the unguarded scope. Going through the guarded one would
  # print a warning for every attribute we look at.
  scope = pkgs.oxcamlPackages.untested;

  candidates = builtins.fromJSON (builtins.readFile candidatesFile);

  # Every attribute here has already survived nix-eval-jobs, so these forces are
  # safe; tryEval is belt and braces for anything that only breaks when a
  # specific field is pulled.
  try =
    default: e:
    let
      r = builtins.tryEval e;
    in
    if r.success then r.value else default;

  pnameOf = name: try null (scope.${name}.pname or null);

  # Dependencies are recorded as pnames, but the scope is keyed by attribute
  # name and the two differ often enough to matter (the `ocaml-lsp` attribute
  # has pname `ocaml-lsp-server`). Invert over the candidates plus everything
  # already supported, so a dependency can be resolved back to an attribute.
  known = lib.unique (
    candidates ++ import ../../../pkgs/development/ocaml-modules/oxcaml/supported.nix
  );

  pnameToAttr = builtins.listToAttrs (
    lib.concatMap (
      name:
      let
        p = pnameOf name;
      in
      lib.optional (p != null) (lib.nameValuePair p name)
    ) known
  );

  depsOf =
    name:
    let
      drv = scope.${name};
      inputs = (drv.propagatedBuildInputs or [ ]) ++ (drv.buildInputs or [ ]);
      pnames = try [ ] (map (d: try null (d.pname or null)) inputs);
      attrs = map (p: if p == null then null else pnameToAttr.${p} or null) pnames;
    in
    lib.unique (builtins.filter (a: a != null && a != name) attrs);
in

lib.genAttrs candidates (name: {
  pname = pnameOf name;
  deps = try [ ] (depsOf name);
})
