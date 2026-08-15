# Growing the OxCaml supported set

`oxcamlPackages` vouches for the attributes listed in
`pkgs/development/ocaml-modules/oxcaml/supported.nix` and warns on everything
else. That warning is a holding position, not an answer: most of the scope has
simply never been tried. This directory is where the tooling to try it lives.

## Running it

```
./oxcaml-triage.py eval     # which attributes evaluate  -> candidates.json
./oxcaml-triage.py graph    # dependency graph           -> graph.json
./oxcaml-triage.py wave     # show the next wave, build nothing
./oxcaml-triage.py build    # build the next wave        -> results.json
./oxcaml-triage.py promote  # names ready for supported.nix
```

`eval` and `graph` need re-running only when the scope changes. `build` takes
`--limit N` and `--timeout SECONDS`; state accumulates in `results.json`, so a
run picks up where the last one stopped and `wave` recomputes as successes
unlock dependents.

Do not pipe `build` through `tail` — it buffers, and the run is long enough that
you want the progress line per package.

### Every build takes a GC root

`build` links each result into `gcroots/`, and that is load bearing rather than
tidy. Nothing in this scope is in a binary cache, and the compiler alone is
roughly a three-quarter-hour build. A garbage collection during a run that held
no roots deletes the compiler along with every package built so far, and the
next build starts by rebuilding the compiler before it can even attempt the
first package. This has already happened once here — an entire verified closure,
collected, with the store 95% free.

If a run does come back to a cold store, rebuild the baseline first, with a root:

```
nix-build . --out-link maintainers/scripts/oxcaml/gcroots/baseline \
  -A oxcamlPackages.janeStreet.bonsai_term -A oxcamlPackages.ocaml-lsp \
  -A oxcamlPackages.ocamlformat -A oxcamlPackages.merlin
```

## Where things stand

Measured 2026-08-14, against the compiler pinned at `5.2.0minus-40`:

| | count |
|---|---|
| attributes in the scope | 1268 |
| vouched for in `supported.nix` | 63 |
| unsupported | 1223 |
| of those, evaluate cleanly | 1148 |
| top-level, so actually promotable | **1128** ← the candidate pool |
| fail at eval, self-excluding | 75 |

(The 20-package gap is `nix-eval-jobs` descending into `recurseIntoAttrs`
sub-sets and reporting children as `reason-native.cli`. Only top-level
attributes are promotable — `supported.nix` and the guard both key on those.)

The 75 need no attention. `buildDunePackage` turns an unsatisfied
`minimalOCamlVersion` into a hard `throw` at evaluation time, and OxCaml's
`5.2.0+ox` compares as `>= 5.2` and `< 5.3`, so packages wanting a newer
compiler exclude themselves. (`maximalOCamlVersion` does not exist in nixpkgs;
upper bounds are spelled `meta.broken = lib.versionAtLeast ocaml.version "5.3"`.)

### Wave 1, first 40 packages

| | |
|---|---|
| pass, tests enabled | 37 |
| fail, `mode` | 2 (`camlpdf`, `clap`) |
| fail, `parsetree` | 1 (`brisk-reconciler`) |
| pass only with `doCheck = false` | 0 |

Do not read 37/40 as a forecast. Wave 1 is the easiest cohort by construction —
every member's dependencies were already vouched for, which mostly selects small
leaf libraries sitting directly on the compiler and dune. The rate should fall
as later waves reach packages that pull in ppx machinery.

The two `mode` failures are the same shape as the fixes already carried for
findlib, yojson and topkg: an implementation infers `@ local` where the `.mli`
declares non-local, e.g.

    val mem : 'a @ local -> 'a list @ local -> bool
    is not included in
    val mem : 'a -> 'a list -> bool

That class is "eta-expand it" and is cheap to fix. `parsetree` is the expensive
one — `brisk-reconciler` wants `pexp_fun` from ppxlib's `Ast_builder`, which the
OxCaml ppxlib fork does not expose, and that is upstream work.

## Order of attack: leaves first

Work up the dependency graph, starting from packages whose dependencies are
already supported.

Nix builds dependencies before dependents regardless, so this ordering is not
needed for the builds to *work*. It is needed to make the results *mean*
anything: a failure is only attributable to a package if everything beneath it
already built. Otherwise root causes and collateral damage are indistinguishable.

- **wave 1** — candidates whose in-scope dependencies are all in `supported.nix`
- **wave n** — dependencies ⊆ supported ∪ everything that passed in waves `< n`

Recompute after each wave; every success unlocks dependents.

## The harness

### `candidates.nix` — dependency graph and wave selection

Follow `maintainers/scripts/haskell/dependencies.nix`, the existing nixpkgs way
to get a dependency graph at eval time without realising anything: read
`propagatedBuildInputs` off each evaluated derivation and map to `pname`. No
`nix-store -q`, no `.drv`. Emit `{ name -> { deps = [ ... ]; } }`.

Read the scope through **`oxcamlPackages.untested`**, or every run trips 1148
warnings.

### `build-wave.sh` — the driver

**Use `nix-eval-jobs`, not a single `builtins.tryEval` sweep.** This is not a
style preference. A one-process `tryEval` pass over the scope dies on
`pkgs/development/tools/ocaml/camlp4/default.nix:96` with an error `tryEval` does
not catch, taking the whole run with it. `nix-eval-jobs` forks a worker per
attribute, which is why nixpkgs uses it at this scale. Use `--no-instantiate`
and `--workers 4` for the eval pass.

Then, per wave:

```
nix-build --keep-going --no-out-link <wave attrs> \
  --option build-timeout <n> --max-jobs <n>
```

`--keep-going` is what stops one failure from aborting the wave. Capture a log
tail per package and append to `results.json`:
`{ name, wave, status, failureClass, log }`.

**Retry failures once with `doCheck = false`.** If the package then passes, its
library is fine and only its test suite breaks — record `status: "pass-nocheck"`.
Under OxCaml this is a large category, which is why it is worth automating rather
than hand-checking.

### Failure classes

Bucket from the log tail:

- `mode` — locality/portability/contention errors (`@ local`, `portable`,
  `contended`). The characteristic OxCaml failure.
- `parsetree` — ppx and `Parsetree`/`Ppat_`/`Pexp_` mismatches. Usually means the
  package needs an oxopam recipe or a fork, not a patch carried here.
- `missing-dep` — `Library "X" not found`, generally a propagation bug and often
  cheaply fixable.
- `test-only` — caught by the retry above.
- `other`.

Before writing any patch, check oxopam for a recipe **at the version this scope
resolves to**. That is already rule 1 in
`pkgs/development/ocaml-modules/oxcaml/README.md`, and the last round found five
vendored patches that had upstream equivalents.

## Promoting a package

In small, reviewable commits, grouped by theme:

1. Add the name to `pkgs/development/ocaml-modules/oxcaml/supported.nix` **and**
   to the "Known to build" list in the README beside it, in the same commit. The
   guard's assertion catches a name that is absent from the scope, but nothing
   catches README drift — so the harness should also check that the two agree.
2. A `pass-nocheck` package additionally needs `doCheck = false` in
   `overrides.nix`, with a comment naming the failing test, per README rule 4.
   `qcheck`, `alcotest`, `gen_js_api` and `re` already do this.
3. Promote only what was actually built. `supported.nix` is a promise, and
   because this scope is deliberately not `recurseIntoAttrs` there is no binary
   cache behind it — every entry is something a user will compile themselves.

After each promotion, confirm nothing moved:

```
nix-build -A oxcamlPackages.janeStreet.bonsai_term \
          -A oxcamlPackages.ocaml-lsp \
          -A oxcamlPackages.ocamlformat \
          -A oxcamlPackages.merlin --no-out-link
```

Adding a name to `supported.nix` only removes a `lib.warn` wrapper, so the store
paths must come out byte-identical.

## Checks the harness itself should pass

- A known-good package (`re`) reports as a pass without rebuilding.
- A known-bad one (`camlp4`) is reported as an eval failure and does not take the
  run down with it.
- `qcheck` with its tests re-enabled comes back `pass-nocheck` — that is exactly
  why it carries `doCheck = false` today.

## Expectations

1148 builds is real compute and should not be attempted in one sitting. Do wave 1
first and measure it; that number sets expectations for everything after.

Expect the pass rate to drop sharply past the leaves. Anything depending on a ppx
inherits the constraints of the `ppxlib` fork, and `parsetree` failures are
usually upstream work rather than something this repo should carry. The honest
end state is a few hundred packages, not 1148. The value is in knowing *which* —
and in never again silently building an unported one.

## Prior art worth copying

- `maintainers/scripts/haskell/dependencies.nix` — eval-time dependency graph.
- `maintainers/scripts/build.nix`, `packagesWith` — guarded scope enumeration.
- `maintainers/scripts/haskell/test-configurations.nix` — the
  `tryEval`-filtered-list into `nix-build --keep-going` pattern.
- `maintainers/scripts/haskell/hydra-report.hs` — how the Haskell set turns build
  results into a checked-in list of what does and does not work.
