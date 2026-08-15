# Patch sets for the OxCaml-specific package builds, taken verbatim from
# oxcaml/opam-repository (see ./opam-repository.nix for the pin). Each list is
# the package opam file's `patches:` field, in the order opam applies them.
# Generated from the opam files; do not reorder.
{
  # ppxlib/ppxlib.0.33.0+ox2
  ppxlib = [
    "dune.patch"
    "location_check.ml.patch"
    "ppxlib+ast+ast.ml.patch"
    "ppxlib+ast+ast_helper_lite.ml.patch"
    "ppxlib+ast+ast_helper_lite.mli.patch"
    "ppxlib+ast+location_error.ml.patch"
    "ppxlib+ast+location_error.mli.patch"
    "ppxlib+ast+supported_version+supported_version.ml.patch"
    "ppxlib+ast+versions.ml.patch"
    "ppxlib+ast+versions.mli.patch"
    "ppxlib+astlib+ast_414.ml.patch"
    "ppxlib+astlib+ast_500.ml.patch"
    "ppxlib+astlib+ast_999.ml.patch"
    "ppxlib+astlib+ast_metadata.mli.patch"
    "ppxlib+astlib+astlib.ml.patch"
    "ppxlib+astlib+cinaps+astlib_cinaps_helpers.ml.patch"
    "ppxlib+astlib+config+gen.ml.patch"
    "ppxlib+astlib+location.ml.patch"
    "ppxlib+astlib+migrate_500_999.ml.patch"
    "ppxlib+astlib+migrate_999_500.ml.patch"
    "ppxlib+astlib+parse.mli.patch"
    "ppxlib+astlib+pprintast.ml.patch"
    "ppxlib+astlib+pprintast.mli.patch"
    "ppxlib+astlib+stdlib0.ml.patch"
    "ppxlib+doc+writing-ppxs.mld.patch"
    "ppxlib+metaquot+ppxlib_metaquot.ml.patch"
    "ppxlib+runner_as_ppx+ppxlib_runner_as_ppx.ml.patch"
    "ppxlib+src+ast_builder.ml.patch"
    "ppxlib+src+ast_builder.mli.patch"
    "ppxlib+src+ast_builder_intf.ml.patch"
    "ppxlib+src+ast_pattern.ml.patch"
    "ppxlib+src+ast_pattern.mli.patch"
    "ppxlib+src+ast_traverse.ml.patch"
    "ppxlib+src+attribute.ml.patch"
    "ppxlib+src+attribute.mli.patch"
    "ppxlib+src+cinaps+ppxlib_cinaps_helpers.ml.patch"
    "ppxlib+src+code_matcher.ml.patch"
    "ppxlib+src+code_matcher.mli.patch"
    "ppxlib+src+common.ml.patch"
    "ppxlib+src+common.mli.patch"
    "ppxlib+src+context_free.ml.patch"
    "ppxlib+src+context_free.mli.patch"
    "ppxlib+src+deriving.ml.patch"
    "ppxlib+src+deriving.mli.patch"
    "ppxlib+src+driver.ml.patch"
    "ppxlib+src+driver.mli.patch"
    "ppxlib+src+extension.ml.patch"
    "ppxlib+src+gen+gen_ast_builder.ml.patch"
    "ppxlib+src+gen+gen_ast_pattern.ml.patch"
    "ppxlib+src+gen+import.ml.patch"
    "ppxlib+src+ignore_unused_warning.ml.patch"
    "ppxlib+src+location.ml.patch"
    "ppxlib+src+location.mli.patch"
    "ppxlib+src+longident.ml.patch"
    "ppxlib+src+longident.mli.patch"
    "ppxlib+src+name.ml.patch"
    "ppxlib+src+ppxlib.ml.patch"
    "ppxlib+src+utils.mli.patch"
    "ppxlib+stdppx+stdppx.ml.patch"
    "ppxlib+traverse+ppxlib_traverse.ml.patch"
    "utils.ml.patch"
  ];
  # ppxlib_ast/ppxlib_ast.0.33.0+ox2
  ppxlib_ast = [
    "dune.patch"
    "location_check.ml.patch"
    "ppxlib+ast+ast.ml.patch"
    "ppxlib+ast+ast_helper_lite.ml.patch"
    "ppxlib+ast+ast_helper_lite.mli.patch"
    "ppxlib+ast+location_error.ml.patch"
    "ppxlib+ast+location_error.mli.patch"
    "ppxlib+ast+supported_version+supported_version.ml.patch"
    "ppxlib+ast+versions.ml.patch"
    "ppxlib+ast+versions.mli.patch"
    "ppxlib+astlib+ast_414.ml.patch"
    "ppxlib+astlib+ast_500.ml.patch"
    "ppxlib+astlib+ast_999.ml.patch"
    "ppxlib+astlib+ast_metadata.mli.patch"
    "ppxlib+astlib+astlib.ml.patch"
    "ppxlib+astlib+cinaps+astlib_cinaps_helpers.ml.patch"
    "ppxlib+astlib+config+gen.ml.patch"
    "ppxlib+astlib+location.ml.patch"
    "ppxlib+astlib+migrate_500_999.ml.patch"
    "ppxlib+astlib+migrate_999_500.ml.patch"
    "ppxlib+astlib+parse.mli.patch"
    "ppxlib+astlib+pprintast.ml.patch"
    "ppxlib+astlib+pprintast.mli.patch"
    "ppxlib+astlib+stdlib0.ml.patch"
    "ppxlib+doc+writing-ppxs.mld.patch"
    "ppxlib+metaquot+ppxlib_metaquot.ml.patch"
    "ppxlib+runner_as_ppx+ppxlib_runner_as_ppx.ml.patch"
    "ppxlib+src+ast_builder.ml.patch"
    "ppxlib+src+ast_builder.mli.patch"
    "ppxlib+src+ast_builder_intf.ml.patch"
    "ppxlib+src+ast_pattern.ml.patch"
    "ppxlib+src+ast_pattern.mli.patch"
    "ppxlib+src+ast_traverse.ml.patch"
    "ppxlib+src+attribute.ml.patch"
    "ppxlib+src+attribute.mli.patch"
    "ppxlib+src+cinaps+ppxlib_cinaps_helpers.ml.patch"
    "ppxlib+src+code_matcher.ml.patch"
    "ppxlib+src+code_matcher.mli.patch"
    "ppxlib+src+common.ml.patch"
    "ppxlib+src+common.mli.patch"
    "ppxlib+src+context_free.ml.patch"
    "ppxlib+src+context_free.mli.patch"
    "ppxlib+src+deriving.ml.patch"
    "ppxlib+src+deriving.mli.patch"
    "ppxlib+src+driver.ml.patch"
    "ppxlib+src+driver.mli.patch"
    "ppxlib+src+extension.ml.patch"
    "ppxlib+src+gen+gen_ast_builder.ml.patch"
    "ppxlib+src+gen+gen_ast_pattern.ml.patch"
    "ppxlib+src+gen+import.ml.patch"
    "ppxlib+src+ignore_unused_warning.ml.patch"
    "ppxlib+src+location.ml.patch"
    "ppxlib+src+location.mli.patch"
    "ppxlib+src+longident.ml.patch"
    "ppxlib+src+longident.mli.patch"
    "ppxlib+src+name.ml.patch"
    "ppxlib+src+ppxlib.ml.patch"
    "ppxlib+src+utils.mli.patch"
    "ppxlib+stdppx+stdppx.ml.patch"
    "ppxlib+traverse+ppxlib_traverse.ml.patch"
    "utils.ml.patch"
  ];
  # re/re.1.14.0+ox
  re = [
    "re+lib+ast.ml.patch"
    "re+lib+ast.mli.patch"
    "re+lib+automata.ml.patch"
    "re+lib+automata.mli.patch"
    "re+lib+bit_vector.mli.patch"
    "re+lib+category.mli.patch"
    "re+lib+color_map.mli.patch"
    "re+lib+compile.ml.patch"
    "re+lib+compile.mli.patch"
    "re+lib+core.mli.patch"
    "re+lib+cset.ml.patch"
    "re+lib+cset.mli.patch"
    "re+lib+dense_map.ml.patch"
    "re+lib+dense_map.mli.patch"
    "re+lib+emacs.mli.patch"
    "re+lib+fmt.mli.patch"
    "re+lib+glob.mli.patch"
    "re+lib+group.mli.patch"
    "re+lib+hash_set.ml.patch"
    "re+lib+hash_set.mli.patch"
    "re+lib+iarray.ml.patch"
    "re+lib+import.ml.patch"
    "re+lib+mark_infos.ml.patch"
    "re+lib+mark_infos.mli.patch"
    "re+lib+parse_buffer.mli.patch"
    "re+lib+pcre.ml.patch"
    "re+lib+pcre.mli.patch"
    "re+lib+perl.mli.patch"
    "re+lib+pmark.ml.patch"
    "re+lib+pmark.mli.patch"
    "re+lib+posix.mli.patch"
    "re+lib+posix_class.mli.patch"
    "re+lib+replace.mli.patch"
    "re+lib+slice.mli.patch"
    "re+lib+view.mli.patch"
    "re+lib_test+expect+re_tests.ml.patch"
    "re+lib_test+expect+test_partial.ml.patch"
    "re+lib_test+expect+test_pcre.ml.patch"
    "re+lib_test+expect+test_pcre_split.ml.patch"
    "re+lib_test+expect+test_re.ml.patch"
    "re+lib_test+re_private.ml.patch"
  ];
  # uutf/uutf.1.0.4+ox
  uutf = [
    "uutf-locals.patch"
    "uutf-portable.patch"
  ];
  # sedlex/sedlex.3.7+ox
  sedlex = [
    "sedlex+syntax+ppx_sedlex.ml.patch"
  ];
  # alcotest/alcotest.1.9.0+ox
  alcotest = [
    "local-restriction.patch"
  ];
  # gen_js_api/gen_js_api.1.1.2+ox
  gen_js_api = [
    "gen-js-api+js_of_ocaml-globalThis.patch"
    "gen-js-api+ppx-driver+gen_js_api_ppx_driver.ml.patch"
    "gen-js-api+ppx-lib+gen_js_api_ppx.ml.patch"
    "gen-js-api+unsafe_multidomain_alert.patch"
    "gen-js-api-ast.patch"
    "dune.patch"
  ];
  # spawn/spawn.v0.15.1+ox
  spawn = [
    "spawn+src+spawn.ml.patch"
    "spawn+src+spawn.mli.patch"
    "spawn+src+spawn_stubs.c.patch"
  ];
  # js_of_ocaml-compiler/js_of_ocaml-compiler.6.3.2+ox
  js_of_ocaml_compiler = [
    "dune.patch"
    "js_of_ocaml-gh2212-draft.patch"
    "js_of_ocaml-internal-obj-changes.patch"
    "js_of_ocaml-fix-build_fs.patch"
    "js_of_ocaml-iarray-primitives.patch"
    "js_of_ocaml-important-config-changes.patch"
    "wasm_of_ocaml-bring-back-eval.patch"
    "js_of_ocaml-revert_9c15703872_behavior_changing_rewrite_of_float_to_bits.patch"
    "js_of_ocaml-stop_evaluating_caml_int64_bits_of_float_to_avoid_breaking_float_u.patch"
    "js_of_ocaml-safepoint-friendly-array-init.patch"
    "js_of_ocaml-cmdliner-compat.patch"
    "js_of_ocaml-disable-ref-unboxing.patch"
    "js_of_ocaml-runtime-bug-fixes.patch"
    "js_of_ocaml-ppx-js-ghost-location.patch"
    "js_of_ocaml-comment-unused.patch"
    "js_of_ocaml-caml_max_domain_count.patch"
    "js_of_ocaml-block-index-primitives.patch"
    "js_of_ocaml-stdlib-float32-abstract.patch"
    "js_of_ocaml-gc-compact-after-bytecode-read.patch"
    "js_of_ocaml-test-oxcaml-compat.patch"
    "js_of_ocaml-unboxed-indexing-small-ints.patch"
  ];
  # js_of_ocaml/js_of_ocaml.6.3.2+ox
  js_of_ocaml = [
    "js_of_ocaml-gh2212-draft.patch"
    "js_of_ocaml-internal-obj-changes.patch"
    "js_of_ocaml-fix-build_fs.patch"
    "js_of_ocaml-iarray-primitives.patch"
    "js_of_ocaml-important-config-changes.patch"
    "wasm_of_ocaml-bring-back-eval.patch"
    "js_of_ocaml-revert_9c15703872_behavior_changing_rewrite_of_float_to_bits.patch"
    "js_of_ocaml-stop_evaluating_caml_int64_bits_of_float_to_avoid_breaking_float_u.patch"
    "js_of_ocaml-safepoint-friendly-array-init.patch"
    "js_of_ocaml-cmdliner-compat.patch"
    "js_of_ocaml-disable-ref-unboxing.patch"
    "js_of_ocaml-runtime-bug-fixes.patch"
    "js_of_ocaml-ppx-js-ghost-location.patch"
    "js_of_ocaml-comment-unused.patch"
    "js_of_ocaml-caml_max_domain_count.patch"
    "js_of_ocaml-block-index-primitives.patch"
    "js_of_ocaml-stdlib-float32-abstract.patch"
    "js_of_ocaml-gc-compact-after-bytecode-read.patch"
    "js_of_ocaml-test-oxcaml-compat.patch"
    "js_of_ocaml-unboxed-indexing-small-ints.patch"
    "dune.patch"
  ];
  # js_of_ocaml-ppx/js_of_ocaml-ppx.6.3.2+ox
  js_of_ocaml_ppx = [
    "js_of_ocaml-gh2212-draft.patch"
    "js_of_ocaml-internal-obj-changes.patch"
    "js_of_ocaml-fix-build_fs.patch"
    "js_of_ocaml-iarray-primitives.patch"
    "js_of_ocaml-important-config-changes.patch"
    "wasm_of_ocaml-bring-back-eval.patch"
    "js_of_ocaml-revert_9c15703872_behavior_changing_rewrite_of_float_to_bits.patch"
    "js_of_ocaml-stop_evaluating_caml_int64_bits_of_float_to_avoid_breaking_float_u.patch"
    "js_of_ocaml-safepoint-friendly-array-init.patch"
    "js_of_ocaml-cmdliner-compat.patch"
    "js_of_ocaml-disable-ref-unboxing.patch"
    "js_of_ocaml-runtime-bug-fixes.patch"
    "js_of_ocaml-ppx-js-ghost-location.patch"
    "js_of_ocaml-comment-unused.patch"
    "js_of_ocaml-caml_max_domain_count.patch"
    "js_of_ocaml-block-index-primitives.patch"
    "js_of_ocaml-stdlib-float32-abstract.patch"
    "js_of_ocaml-gc-compact-after-bytecode-read.patch"
    "js_of_ocaml-test-oxcaml-compat.patch"
    "js_of_ocaml-unboxed-indexing-small-ints.patch"
    "dune.patch"
  ];
  # notty-community/notty-community.0.2.4+ox2
  notty_community = [
    "notty-disable_unsafe_multidomain.patch"
    "notty-use_correct_newline_escape_code_and_stop_clearing_the_last_text_element_of_a_line.patch"
    "notty-different_kinds_of_cursors.patch"
    "notty-use_newline_instead_of_cursor_nextline_for_emacs_support.patch"
    "notty-expose_fast_tty_width.patch"
    "notty-do_not_send_clear_eol_on_full_lines.patch"
    "notty-ctrl_backspace.patch"
    "notty-reset-cursor-on-release.patch"
    "notty-line_based_diffing_and_patching.patch"
    "notty-defensively-ignore-corrupted-x10-vscode-mouse-codes.patch"
    "notty-portabilize_notty_unix.patch"
    "notty-add_href_support.patch"
    "notty-default_color.patch"
    "notty-set_save_and_restore_title.patch"
    "notty-synchronized_output.patch"
    "notty-expose-Text.graphemes.patch"
    "notty-vs16_makes_characters_look_like_emojis.patch"
    "notty-expose_operation_intermediate_representation.patch"
    "notty-dynamic_mouse_reporting.patch"
    "notty-hover_events.patch"
    "dune.patch"
    "lwt.patch"
  ];

  # merlin/merlin.5.2.1-502+ox2. Shared by merlin-lib, dot-merlin-reader and
  # ocaml-index, which oxopam builds from the same tree with the same patch.
  merlin = [
    "merlin-minus39-standalone.patch"
  ];

  # cmarkit/cmarkit.0.3.0+ox
  cmarkit = [
    "oxcaml-cmarkit.patch"
  ];

  # ocamlfind/ocamlfind.1.9.8+ox
  ocamlfind = [
    "oxcaml-ocamlfind.patch"
  ];

  # ocamlbuild/ocamlbuild.0.16.1+ox
  ocamlbuild = [
    "flambda2.patch"
  ];

  # ocaml-compiler-libs/ocaml-compiler-libs.v0.17.0+ox
  ocaml_compiler_libs = [
    "read_cma.patch"
  ];

  # topkg/topkg.1.1.1+ox
  topkg = [
    "topkg_string.patch"
  ];

  # lwt/lwt.5.9.2+ox
  lwt = [
    "oxcaml-lwt.patch"
  ];

  # ctypes/ctypes.0.24.0+ox
  ctypes = [
    "bigarray.patch"
  ];

  # extlib/extlib.1.8.0+ox
  extlib = [
    "oxcaml.patch"
  ];
}
