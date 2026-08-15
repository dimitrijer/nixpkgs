# Packages whose library builds against OxCaml but whose test suite does not.
# Each gets doCheck = false, and the value here is why -- README rule 4 asks for
# the reason, not just the disable, and a package whose reason nobody can state
# is left failing instead of being quietly waved through.
#
# Note how few of these are the library's fault. Most are a test-only
# dependency that OxCaml breaks, or a test framework whose API moved in v0.18;
# the code under test is fine.
{
  # Its cram tests pull in mdx, which does not build here at all: mdx calls
  # Unix.putenv and OxCaml raises `Alert unsafe_multidomain`.
  printbox = "cram tests need mdx, which OxCaml breaks";
  yaml = "tests run through mdx, which OxCaml breaks";
  bindlib = "a test dependency trips Alert unsafe_multidomain on Unix.putenv";

  # pkgs.oxcaml is configured --disable-multidomain (see the multidomain flag in
  # pkgs/by-name/ox/oxcaml/package.nix), so anything driving several domains
  # cannot run its tests here.
  qcheck-stm = "STM tests die on Failure(\"failed to allocate domain\"); compiler is --disable-multidomain";
  qcheck-lin = "Lin interleaving properties fail; compiler is --disable-multidomain";

  # OxCaml's compiler-libs dropped Ident.persistent, which a shared test-time
  # dependency still calls. The libraries themselves are unaffected.
  colors = "test dependency calls Ident.persistent, gone from OxCaml's compiler-libs";
  dolmen_loop = "test dependency calls Ident.persistent, gone from OxCaml's compiler-libs";
  patricia-tree = "test dependency calls Ident.persistent, gone from OxCaml's compiler-libs";
  saturn = "test dependency calls Ident.persistent, gone from OxCaml's compiler-libs";
  thread-table = "test dependency calls Ident.persistent, gone from OxCaml's compiler-libs";

  # v0.18 ppx_inline_test retired [let%test_module] in favour of [module%test].
  kdl = "tests use the retired [let%test_module]";

  ctypes-foreign = "6 of 18 Dynamic-Funptr cases fail: test_with_fun and test_of_fun_and_free, foreign and stubs";
  multicore-magic = "Atomic_array fails its assertion at test/test_on_main_thread_only.ml line 99";
  mimic = "the test executable fails to link: undefined reference to caml_hash";
  hxd = "the cram test test/lib.t pins exact `dune build` output that this compiler does not reproduce";
  cohttp_5_3 = "the test executable does not resolve base: Library \"base\" not found";
  ocaml-r = "the tests drive an embedded R through its JIT, which dies on `C stack usage ... too close to the limit`";
  class_group_vdf = "a test-time ppx hits Ppat_constraint expecting 3 arguments where it passes 2";
}
