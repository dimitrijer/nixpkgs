#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 nix-eval-jobs
"""Find out which of the OxCaml scope's packages actually build.

See ./README.md for the why. In short: oxcamlPackages inherits ~1250 package
definitions and vouches for a few dozen, and this walks the rest from the leaves
up, recording what builds so it can be promoted into supported.nix.

    ./oxcaml-triage.py eval     # which attributes evaluate  -> candidates.json
    ./oxcaml-triage.py graph    # dependency graph           -> graph.json
    ./oxcaml-triage.py wave     # show the next wave, build nothing
    ./oxcaml-triage.py build    # build the next wave        -> results.json
    ./oxcaml-triage.py promote  # names ready for supported.nix

State accumulates in results.json, so a run picks up where the last one stopped.
"""

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
NIXPKGS = HERE.parent.parent.parent
SUPPORTED_NIX = NIXPKGS / "pkgs/development/ocaml-modules/oxcaml/supported.nix"

CANDIDATES = HERE / "candidates.json"
GRAPH = HERE / "graph.json"
RESULTS = HERE / "results.json"
# Which failures also fail on a stock compiler -- see cmd_control.
CONTROL = HERE / "control.json"

# Every build here takes an --out-link into this directory, which registers an
# indirect GC root. This is not tidiness: without roots, a garbage collection
# part-way through a run deletes the OxCaml compiler along with everything built
# so far, and every subsequent build has to rebuild the compiler first -- three
# quarters of an hour before the first package is even attempted. That has
# already happened once.
GCROOTS = HERE / "gcroots"

# Enough of the tail to classify a failure without checking in whole build logs.
LOG_TAIL_LINES = 40

# Lines worth centring an excerpt on. `make: *** [...] Error 2` is deliberately
# not here: it is what make prints *after* the compiler already said something
# useful, so anchoring on it lands below the actual diagnosis -- which is how
# apron, lablgtk, labltk and ocamlscript ended up unexplained.
ERROR_LINE = re.compile(
    r"^\s*>?\s*(Error|Alert|error):"
    # Test frameworks do not say "Error:". alcotest prints [FAIL] and
    # [exception], and a run that ends that way leaves no Error: line in
    # the whole log -- which is why multicore-magic looked, for three
    # separate runs, like a build whose tests had passed.
    r"|^\s*>?\s*\[(FAIL|exception)\]|Assertion failed",
    re.MULTILINE,
)
# nix talking about the build rather than the builder talking about the code.
NIX_META_ERROR = re.compile(r"error: (Cannot build|build of|builder for)")

# Ordered: first match wins, so the specific OxCaml signatures come before the
# generic ones. See ./README.md for what each class implies about the fix.
FAILURE_CLASSES = [
    # Not an OxCaml problem at all: a dead source URL or a bad hash. These say
    # nothing about whether the package would build, so they must not be
    # counted against the compiler -- codicons 404s, and would have been filed
    # as an OxCaml incompatibility otherwise.
    ("fetch", r"cannot download source|curl: \(22\)|hash mismatch|unable to download|404 Not Found"),
    # The mode system. The second alternation is the one that reads least like
    # a mode error and is easy to miss: OxCaml phrases a plain locality
    # mismatch as "This value is local but is expected to be global."
    ("mode", r"@ local|\blocal_\b|is not portable|portability|contended|@@ portable|unsafe_multidomain"
             r"|This value is local|escapes its region|expected to be global"),
    # A ppx reaching into ppxlib's AST, which the OxCaml ppxlib fork reshapes.
    ("parsetree", r"Ppat_|Pexp_|Ptyp_|Parsetree|ppxlib|Ast_helper|ppx_|pval_modalities|pval_poly"),
    # Reaching into the compiler's own internals -- Types, Lambda, Cmo_format --
    # whose constructor arities OxCaml changes. Distinguished from an ordinary
    # type error by being an arity complaint about a compiler-libs type, e.g.
    # "The constructor Lswitch expects 4 argument(s)". Fixing these means
    # tracking compiler internals, so they are usually upstream work.
    ("compiler-libs", r"(constructor|type constructor) \S+ expects \d+ argument"),
    # A C stub or vendored C header that the OxCaml headers disagree with.
    # Nothing to do with the type system; usually an ordinary porting fix.
    ("c-stubs", r"error: expected identifier|\.[ch]:\d+:\d+: (error|note)|undefined reference to"),
    # The .ml and .mli disagree. Under OxCaml this is very often a mode
    # mismatch whose detail sits further down the log than the excerpt reaches,
    # so treat it as its own class rather than folding it into type-error --
    # these are worth opening, and are frequently a one-line eta-expansion.
    ("signature", r"Modules do not match|does not match the interface"
                  r"|contains the description for unit"),
    ("inline-test", r"let%test_module|inline-test-allow-let-test-module"),
    ("missing-dep", r'Library "[^"]+" not found|Unbound module|cannot find file'),
    ("type-error", r"This expression has type|Signature mismatch|Type error"
                  r"|variant or record definition does not match"
                  r"|with constraint, the new definition"),
    # Last on purpose: this is nix reporting that something below failed, so it
    # is only the right answer when no log in the closure explained itself.
    # 146 packages sat in "other" for this reason alone.
    ("dep-failed", r"Reason: 1 dependency failed|dependency failed"),
]


def run(cmd, **kw):
    # Packages this triage has already broken are marked meta.broken in
    # broken.nix, which would otherwise stop the triage from ever re-testing
    # them -- and re-testing is exactly how a fix gets confirmed.
    env = {**os.environ, "NIXPKGS_ALLOW_BROKEN": "1"}
    return subprocess.run(cmd, cwd=NIXPKGS, text=True, env=env, **kw)


def load(path, default):
    return json.loads(path.read_text()) if path.exists() else default


def save(path, obj):
    path.write_text(json.dumps(obj, indent=2, sort_keys=True) + "\n")


def supported_names():
    """The allowlist, read out of the Nix file rather than duplicated here."""
    out = run(
        ["nix-instantiate", "--eval", "--strict", "--json", "-E",
         f"import {SUPPORTED_NIX}"],
        capture_output=True,
    )
    if out.returncode != 0:
        sys.exit(f"could not read {SUPPORTED_NIX}:\n{out.stderr}")
    return set(json.loads(out.stdout))


# --- eval ------------------------------------------------------------------

EVAL_EXPR = """
let
  pkgs = import %s { };
  lib = pkgs.lib;
  scope = pkgs.oxcamlPackages.untested;
  supported = import %s;
  names = lib.subtractLists supported (lib.attrNames scope);
in lib.genAttrs names (n: scope.${n})
"""


def cmd_eval(args):
    """Which attributes evaluate? One nix-eval-jobs worker per attribute.

    A plain tryEval sweep cannot do this: it does not catch the error camlp4
    raises, and that one attribute aborts the whole evaluation.
    """
    print("evaluating the scope (a few minutes)...", file=sys.stderr)
    proc = run(
        ["nix-eval-jobs", "--no-instantiate", "--workers", str(args.workers),
         "--expr", EVAL_EXPR % (NIXPKGS, SUPPORTED_NIX)],
        capture_output=True,
    )

    ok, failed, nested = [], {}, []
    for line in proc.stdout.splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            rec = json.loads(line)
        except json.JSONDecodeError:
            continue
        attr = rec.get("attr")
        if not attr:
            continue
        # nix-eval-jobs descends into recurseIntoAttrs sub-sets and reports
        # their children as "reason-native.cli". Only top-level attributes are
        # promotable -- supported.nix and the guard both key on those -- so a
        # dotted name is not a candidate.
        if "." in attr:
            nested.append(attr)
            continue
        if rec.get("error"):
            failed[attr] = " ".join(rec["error"].split())[:200]
        else:
            ok.append(attr)

    ok.sort()
    save(CANDIDATES, ok)
    save(HERE / "eval-failures.json", failed)
    print(f"{len(ok)} evaluate, {len(failed)} do not "
          f"(mostly minimalOCamlVersion, which throws at eval time)"
          + (f", {len(nested)} skipped as nested" if nested else ""))


# --- graph -----------------------------------------------------------------

def cmd_graph(args):
    if not CANDIDATES.exists():
        sys.exit("run `eval` first")
    print("building the dependency graph...", file=sys.stderr)
    out = run(
        ["nix-instantiate", "--eval", "--strict", "--json",
         str(HERE / "graph.nix"), "--argstr", "candidatesFile", str(CANDIDATES)],
        capture_output=True,
    )
    if out.returncode != 0:
        sys.exit(out.stderr)
    save(GRAPH, json.loads(out.stdout))
    print(f"graph for {len(json.loads(out.stdout))} packages -> {GRAPH.name}")


# --- waves -----------------------------------------------------------------

def all_unattempted():
    """Everything never tried, whether or not its dependencies settled.

    The wave deliberately withholds these so a failure stays attributable. This
    is the escape hatch: a package blocked by, say, mdx may only want it for its
    tests, and the dependency graph here is built from propagatedBuildInputs
    plus buildInputs, which cannot tell a test-only edge from a real one. The
    only way to find out is to build it.
    """
    graph = load(GRAPH, {})
    results = load(RESULTS, {})
    settled = supported_names() | {
        n for n, r in results.items() if r["status"].startswith("pass")
    }
    return sorted(n for n in graph if n not in results and n not in settled)


def compute_wave():
    """Packages whose dependencies are all settled.

    Nix would build in dependency order regardless; the point of the ordering is
    that a failure is only attributable to a package once everything beneath it
    has built.
    """
    graph = load(GRAPH, {})
    if not graph:
        sys.exit("run `graph` first")
    results = load(RESULTS, {})
    settled = supported_names() | {
        n for n, r in results.items() if r["status"].startswith("pass")
    }
    done = set(results)
    return sorted(
        name for name, info in graph.items()
        if name not in done and name not in settled
        and all(d in settled for d in info["deps"])
    )


def cmd_wave(args):
    wave = compute_wave()
    print(f"{len(wave)} packages ready to try:\n")
    for n in wave:
        print(f"  {n}")


# --- build -----------------------------------------------------------------

def classify(log):
    # Collapse whitespace first. OCaml wraps diagnostics across lines, and the
    # builder prefixes each with "> ", so "This value is local but is expected
    # to be global" reaches us split in two -- containers was filed as "other"
    # for exactly that reason. Matching on one long line makes the patterns
    # insensitive to where the compiler chose to break.
    flat = re.sub(r"\s*\n\s*>?\s*", " ", log)
    for name, pattern in FAILURE_CLASSES:
        if re.search(pattern, flat, re.IGNORECASE):
            return name
    return "other"


def build_one(attr, no_check=False, timeout=1800, max_jobs=1, cores=2):
    """Build one attribute. Returns (ok, log_tail)."""
    GCROOTS.mkdir(exist_ok=True)
    link = GCROOTS / (attr + ("-nocheck" if no_check else ""))
    # A single ocamlopt.opt peaks around 2.4G on this stack, so the stock
    # max-jobs 4 / cores 4 puts ~10G in flight and the OOM killer takes the
    # build out with "Command got signal KILL" -- which reads like a compiler
    # crash rather than the memory problem it is. Cap concurrency instead.
    limits = ["--max-jobs", str(max_jobs), "--cores", str(cores)]
    if no_check:
        # Quoted selection: plenty of these names are not bare Nix identifiers.
        expr = (f'(import {NIXPKGS} {{}}).oxcamlPackages.untested."{attr}"'
                f".overrideAttrs {{ doCheck = false; }}")
        cmd = ["nix-build", "--out-link", str(link), *limits, "-E", expr]
    else:
        cmd = ["nix-build", "--out-link", str(link), *limits, "-A",
               f"oxcamlPackages.untested.{attr}"]
    try:
        p = run(cmd, capture_output=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        return False, "TIMEOUT"
    if p.returncode == 0:
        return True, ""
    return False, failure_excerpt(p.stderr)


def failure_excerpt(stderr):
    """The part of a failed build a human actually needs.

    Two things make this more than a tail. nix-build's stderr stops echoing the
    builder past a certain size and prints a "For full logs, run: nix-store -l"
    pointer instead, so the compiler error is not in stderr at all. And when the
    thing that failed is a *dependency* -- codicons' source fetch, printbox's
    mdx -- the explanation is in that other derivation's log, not this one's.
    So collect every .drv nix mentioned and read all of their logs.
    """
    drvs = list(dict.fromkeys(re.findall(r"(/nix/store/\S+\.drv)", stderr)))
    logs = []
    for d in drvs:
        got = run(["nix", "log", d], capture_output=True)
        if got.returncode == 0 and got.stdout.strip():
            logs.append(got.stdout)
    blob = "\n\n".join(logs) if logs else stderr

    # Centre on the first real diagnosis rather than the tail: a make-driven
    # build prints `make: *** Error 2` long after the compiler explained itself,
    # so the last 40 lines are the least informative part of the log.
    lines = blob.splitlines()
    # The *last* error, not the first: a build fails at the end, and the logs of
    # several derivations are concatenated here, so the first match is as likely
    # to be an include trace or a dependency's passing test output as the actual
    # diagnosis. Anchoring on the first is what left bjack and saturn_lockfree
    # unexplained despite their real errors being present.
    hits = [h for h in ERROR_LINE.finditer(blob)
            if not NIX_META_ERROR.match(h.group(0).strip())]
    if not hits:
        hits = list(ERROR_LINE.finditer(blob))
    if hits:
        i = blob[: hits[-1].start()].count("\n")
        return "\n".join(lines[max(0, i - 8): i + 20])
    return "\n".join(lines[-LOG_TAIL_LINES:])


def cmd_build(args):
    wave = all_unattempted() if args.include_blocked else compute_wave()
    if args.limit:
        wave = wave[: args.limit]
    if not wave:
        print("nothing ready to build")
        return

    results = load(RESULTS, {})
    print(f"building {len(wave)} packages\n", file=sys.stderr)

    for i, attr in enumerate(wave, 1):
        print(f"[{i}/{len(wave)}] {attr} ... ", end="", flush=True)
        ok, log = build_one(attr, timeout=args.timeout,
                            max_jobs=args.max_jobs, cores=args.cores)

        if ok:
            results[attr] = {"status": "pass"}
            print("pass")
        else:
            # "The library builds but its test suite trips mode checking" is a
            # whole category under OxCaml, not an edge case, so it is worth one
            # automatic retry before recording a failure.
            ok2, log2 = build_one(attr, no_check=True, timeout=args.timeout,
                                  max_jobs=args.max_jobs, cores=args.cores)
            if ok2:
                results[attr] = {"status": "pass-nocheck", "log": log}
                print("pass (tests disabled)")
            else:
                results[attr] = {
                    "status": "fail",
                    "failureClass": classify(log2),
                    "log": log2,
                }
                print(f"FAIL ({results[attr]['failureClass']})")

        save(RESULTS, results)

    summarise(results)


def summarise(results):
    counts = {}
    for r in results.values():
        key = r["status"] if r["status"] != "fail" else f"fail:{r['failureClass']}"
        counts[key] = counts.get(key, 0) + 1
    print("\n--- totals ---")
    for k in sorted(counts):
        print(f"  {counts[k]:5d}  {k}")


# --- promote ---------------------------------------------------------------

def cmd_control(args):
    """Does each failure build on a *stock* compiler?

    A package that fails here as well is not an OxCaml problem, and saying so
    in the OxCaml scope would misattribute it -- codicons has a dead source URL,
    apron disagrees with its own C headers, ocaml-r cannot start an embedded R.
    Only a package that builds on stock OCaml and fails under OxCaml has been
    broken *by* OxCaml.

    ocamlPackages_5_2 is the control because OxCaml reports 5.2.0+ox. It is a
    Hydra-built set, so most of this is substituted rather than compiled.
    """
    results = load(RESULTS, {})
    control = load(CONTROL, {})
    failures = sorted(n for n, r in results.items() if r["status"] == "fail")
    todo = [n for n in failures if n not in control]
    print(f"{len(failures)} failures, {len(todo)} to check on ocamlPackages_5_2\n")

    for i, attr in enumerate(todo, 1):
        print(f"[{i}/{len(todo)}] {attr} ... ", end="", flush=True)
        try:
            # ocamlPackages_5_2 is NOT a top-level attribute; it lives under
            # ocaml-ng. Getting this wrong makes every control "fail" with
            # "attribute not found", which is indistinguishable from a real
            # build failure unless you look -- see the verdict handling below.
            p = run(["nix-build", "--no-out-link", "--max-jobs", str(args.max_jobs),
                     "--cores", str(args.cores),
                     "-A", f"ocaml-ng.ocamlPackages_5_2.{attr}"],
                    capture_output=True, timeout=args.timeout)
            if p.returncode == 0:
                verdict = "builds"
            elif re.search(r"attribute '[^']+' (in selection path )?.*not found"
                           r"|error: attribute", p.stderr):
                # Nix could not even resolve it: says nothing about building.
                verdict = "absent"
            else:
                verdict = "fails-too"
        except subprocess.TimeoutExpired:
            verdict = "timeout"
        control[attr] = verdict
        print(verdict)
        save(CONTROL, control)

    from collections import Counter
    tally = Counter(control.get(n, "?") for n in failures)
    print("\n" + "  ".join(f"{v} {k}" for k, v in sorted(tally.items())))
    if tally.get("absent") == len(failures):
        print("every control was 'absent' -- the attribute path is wrong, "
              "not the packages")


def cmd_reclassify(args):
    """Re-sort recorded failures after a change to FAILURE_CLASSES.

    Pure bookkeeping over stored logs -- nothing is rebuilt. Only useful where
    the stored log already contains the diagnosis; where it does not, the entry
    stays "other" and wants a real re-run (see `requeue`).
    """
    results = load(RESULTS, {})
    changed = 0
    stale = []
    for name, r in sorted(results.items()):
        if r["status"] != "fail":
            continue
        new = classify(r.get("log", ""))
        if new == "other" and r.get("failureClass") not in (None, "other"):
            # The stored log cannot justify the old class -- that is a gap in
            # what was recorded, not evidence the class was wrong. Leave it and
            # let `requeue` force a real rebuild.
            stale.append(name)
            continue
        if new != r.get("failureClass"):
            print(f"  {name}: {r.get('failureClass')} -> {new}")
            r["failureClass"] = new
            changed += 1
    save(RESULTS, results)
    print(f"\n{changed} reclassified")
    if stale:
        print(f"{len(stale)} kept, stored log too short to re-judge: "
              + ", ".join(sorted(stale)))
    summarise(results)


def cmd_requeue(args):
    """Forget results in a given class so the next `build` re-attempts them."""
    results = load(RESULTS, {})
    gone = [n for n, r in results.items()
            if r["status"] == "fail"
            and (args.failure_class == "all"
                 or r.get("failureClass") == args.failure_class)]
    for n in gone:
        del results[n]
    save(RESULTS, results)
    print(f"re-queued {len(gone)}: {', '.join(sorted(gone))}")


def cmd_promote(args):
    """Names ready to be added to supported.nix, and which need doCheck."""
    results = load(RESULTS, {})
    already = supported_names()
    clean = sorted(n for n, r in results.items()
                   if r["status"] == "pass" and n not in already)
    nocheck = sorted(n for n, r in results.items()
                     if r["status"] == "pass-nocheck" and n not in already)

    if clean:
        print("# build with their test suites -- add to supported.nix:")
        for n in clean:
            print(f'  "{n}"')
    if nocheck:
        print("\n# build only with doCheck = false -- these ALSO need an entry")
        print("# in overrides.nix naming the failing test (README rule 4):")
        for n in nocheck:
            print(f'  "{n}"')
    if not clean and not nocheck:
        print("nothing to promote yet")


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    e = sub.add_parser("eval", help="which attributes evaluate")
    e.add_argument("--workers", type=int, default=4)
    e.set_defaults(func=cmd_eval)

    g = sub.add_parser("graph", help="dependency graph")
    g.set_defaults(func=cmd_graph)

    w = sub.add_parser("wave", help="show the next wave")
    w.set_defaults(func=cmd_wave)

    b = sub.add_parser("build", help="build the next wave")
    b.add_argument("--limit", type=int, help="only the first N")
    b.add_argument("--include-blocked", action="store_true",
                   help="also try packages whose dependencies have not settled")
    b.add_argument("--timeout", type=int, default=1800, help="per package, seconds")
    b.add_argument("--max-jobs", type=int, default=1,
                   help="concurrent derivations (memory, not speed, is the limit)")
    b.add_argument("--cores", type=int, default=2, help="cores within one derivation")
    b.set_defaults(func=cmd_build)

    c = sub.add_parser("control", help="do the failures build on stock 5.2?")
    c.add_argument("--timeout", type=int, default=1800)
    c.add_argument("--max-jobs", type=int, default=1)
    c.add_argument("--cores", type=int, default=2)
    c.set_defaults(func=cmd_control)

    rc = sub.add_parser("reclassify", help="re-sort stored failures, no rebuilds")
    rc.set_defaults(func=cmd_reclassify)

    rq = sub.add_parser("requeue", help="forget a failure class so build retries it")
    rq.add_argument("failure_class")
    rq.set_defaults(func=cmd_requeue)

    p = sub.add_parser("promote", help="what is ready for supported.nix")
    p.set_defaults(func=cmd_promote)

    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
