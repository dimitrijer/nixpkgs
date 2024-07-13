{ self
, bash
, fetchpatch
, fzf
, lib
, openssl
, zstd
, krb5
}:

with self;

{

  abstract_algebra = janePackage {
    pname = "abstract_algebra";
    hash = lib.fakeSha256;
    meta.description = "A small library describing abstract algebra concepts";
    propagatedBuildInputs = [ base ppx_jane ];
  };

  accessor = janePackage {
    pname = "accessor";
    hash = lib.fakeSha256;
    meta.description = "A library that makes it nicer to work with nested functional data structures";
    propagatedBuildInputs = [ higher_kinded ];
  };

  accessor_async = janePackage {
    pname = "accessor_async";
    hash = lib.fakeSha256;
    meta.description = "Accessors for Async types, for use with the Accessor library";
    propagatedBuildInputs = [ accessor_core async_kernel ];
  };

  accessor_base = janePackage {
    pname = "accessor_base";
    hash = lib.fakeSha256;
    meta.description = "Accessors for Base types, for use with the Accessor library";
    propagatedBuildInputs = [ ppx_accessor ];
  };

  accessor_core = janePackage {
    pname = "accessor_core";
    hash = lib.fakeSha256;
    meta.description = "Accessors for Core types, for use with the Accessor library";
    propagatedBuildInputs = [ accessor_base core_kernel ];
  };

  async = janePackage {
    pname = "async";
    hash = lib.fakeSha256;
    meta.description = "Monadic concurrency library";
    propagatedBuildInputs = [ async_rpc_kernel async_unix textutils ];
    doCheck = false; # we don't have netkit_sockets
  };

  async_durable = janePackage {
    pname = "async_durable";
    hash = lib.fakeSha256;
    meta.description = "Durable connections for use with async";
    propagatedBuildInputs = [ async_kernel async_rpc_kernel core core_kernel ppx_jane ];
  };

  async_extra = janePackage {
    pname = "async_extra";
    hash = lib.fakeSha256;
    meta.description = "Monadic concurrency library";
    propagatedBuildInputs = [ async_kernel ];
  };

  async_find = janePackage {
    pname = "async_find";
    hash = lib.fakeSha256;
    meta.description = "Directory traversal with Async";
    propagatedBuildInputs = [ async ];
  };

  async_inotify = janePackage {
    pname = "async_inotify";
    hash = lib.fakeSha256;
    meta.description = "Async wrapper for inotify";
    propagatedBuildInputs = [ async_find inotify ];
  };

  async_interactive = janePackage {
    pname = "async_interactive";
    hash = lib.fakeSha256;
    meta.description = "Utilities for building simple command-line based user interfaces";
    propagatedBuildInputs = [ async ];
  };

  async_js = janePackage {
    pname = "async_js";
    hash = lib.fakeSha256;
    meta.description = "A small library that provide Async support for JavaScript platforms";
    buildInputs = [ js_of_ocaml-ppx ];
    propagatedBuildInputs = [ async_rpc_kernel js_of_ocaml uri-sexp ];
  };

  async_kernel = janePackage {
    pname = "async_kernel";
    hash = lib.fakeSha256;
    meta.description = "Monadic concurrency library";
    propagatedBuildInputs = [ core_kernel ];
  };

  async_rpc_kernel = janePackage {
    pname = "async_rpc_kernel";
    hash = lib.fakeSha256;
    meta.description = "Platform-independent core of Async RPC library";
    propagatedBuildInputs = [ async_kernel protocol_version_header ];
  };

  async_rpc_websocket = janePackage {
    pname = "async_rpc_websocket";
    hash = lib.fakeSha256;
    meta.description = "Library to serve and dispatch Async RPCs over websockets";
    propagatedBuildInputs = [ async_rpc_kernel async_websocket cohttp_async_websocket ];
  };

  async_sendfile = janePackage {
    pname = "async_sendfile";
    hash = lib.fakeSha256;
    meta.description = "Thin wrapper around [Linux_ext.sendfile] to send full files";
    propagatedBuildInputs = [ async_unix ];
  };

  async_shell = janePackage {
    pname = "async_shell";
    hash = lib.fakeSha256;
    meta.description = "Shell helpers for Async";
    propagatedBuildInputs = [ async shell ];
  };

  async_smtp = janePackage {
    pname = "async_smtp";
    hash = lib.fakeSha256;
    meta.description = "SMTP client and server";
    propagatedBuildInputs = [ async_extra async_inotify async_sendfile async_shell async_ssl email_message resource_cache re2_stable sexp_macro ];
  };

  async_ssl = janePackage {
    version = "0.16.1";
    pname = "async_ssl";
    hash = lib.fakeSha256;
    meta.description = "Async wrappers for SSL";
    buildInputs = [ dune-configurator ];
    propagatedBuildInputs = [ async ctypes ctypes-foreign openssl ];
  };

  async_unix = janePackage {
    pname = "async_unix";
    hash = lib.fakeSha256;
    meta.description = "Monadic concurrency library";
    propagatedBuildInputs = [ async_kernel core_unix ];
  };

  async_websocket = janePackage {
    pname = "async_websocket";
    hash = lib.fakeSha256;
    meta.description = "A library that implements the websocket protocol on top of Async";
    propagatedBuildInputs = [ async cryptokit ];
  };

  babel = janePackage {
    pname = "babel";
    hash = lib.fakeSha256;
    meta.description = "A library for defining Rpcs that can evolve over time without breaking backward compatibility";
    propagatedBuildInputs = [ async_rpc_kernel core ppx_jane streamable tilde_f ];
  };

  base = janePackage {
    pname = "base";
    version = "0.16.2";
    hash = lib.fakeSha256;
    meta.description = "Full standard library replacement for OCaml";
    buildInputs = [ dune-configurator ];
    propagatedBuildInputs = [ sexplib0 ];
    checkInputs = [ alcotest ];
  };

  base_bigstring = janePackage {
    pname = "base_bigstring";
    hash = lib.fakeSha256;
    meta.description = "String type based on [Bigarray], for use in I/O and C-bindings";
    propagatedBuildInputs = [ int_repr ppx_jane ];
  };

  base_trie = janePackage {
    pname = "base_trie";
    hash = lib.fakeSha256;
    meta.description = "Trie data structure library";
    propagatedBuildInputs = [ base core expect_test_helpers_core ppx_jane ];
  };

  base_quickcheck = janePackage {
    pname = "base_quickcheck";
    hash = lib.fakeSha256;
    meta.description = "Randomized testing framework, designed for compatibility with Base";
    propagatedBuildInputs = [ ppx_base ppx_fields_conv ppx_let ppx_sexp_value splittable_random ];
  };

  bidirectional_map = janePackage {
    pname = "bidirectional_map";
    hash = lib.fakeSha256;
    meta.description = "A library for bidirectional maps and multimaps";
  };

  bignum = janePackage {
    pname = "bignum";
    hash = lib.fakeSha256;
    propagatedBuildInputs = [ core_kernel zarith zarith_stubs_js ];
    meta.description = "Core-flavoured wrapper around zarith's arbitrary-precision rationals";
  };

  bin_prot = janePackage {
    pname = "bin_prot";
    hash = lib.fakeSha256;
    meta.description = "A binary protocol generator";
    propagatedBuildInputs = [ ppx_compare ppx_custom_printf ppx_fields_conv ppx_optcomp ppx_stable_witness ppx_variants_conv ];
  };

  bonsai = janePackage {
    pname = "bonsai";
    hash = lib.fakeSha256;
    meta.description = "A library for building dynamic webapps, using Js_of_ocaml";
    buildInputs = [ ppx_pattern_bind ];
    nativeBuildInputs = [ ppx_css js_of_ocaml-compiler ocaml-embed-file ];
    propagatedBuildInputs = [
      async
      async_durable
      async_extra
      async_rpc_websocket
      babel
      cohttp-async
      core_bench
      fuzzy_match
      incr_dom
      indentation_buffer
      js_of_ocaml-ppx
      ordinal_abbreviation
      patdiff
      polling_state_rpc
      ppx_css
      ppx_typed_fields
      profunctor
      sexp_grammar
      textutils
    ];
  };

  cinaps = janePackage {
    pname = "cinaps";
    version = "0.15.1";
    hash = lib.fakeSha256;
    meta.description = "Trivial metaprogramming tool";
    minimalOCamlVersion = "4.04";
    propagatedBuildInputs = [ re ];
    doCheck = false; # fails because ppx_base doesn't include ppx_js_style
  };

  cohttp_async_websocket = janePackage {
    pname = "cohttp_async_websocket";
    hash = lib.fakeSha256;
    meta.description = "Websocket library for use with cohttp and async";
    propagatedBuildInputs = [ async_websocket cohttp-async ppx_jane uri-sexp ];
  };

  cohttp_static_handler = janePackage {
    pname = "cohttp_static_handler";
    hash = lib.fakeSha256;
    meta.description = "A library for easily creating a cohttp handler for static files";
    propagatedBuildInputs = [ cohttp-async ];
  };

  content_security_policy = janePackage {
    pname = "content_security_policy";
    hash = lib.fakeSha256;
    meta.description = "A library for building content-security policies";
    propagatedBuildInputs = [ core ppx_jane ];
  };

  core = janePackage {
    pname = "core";
    version = "0.16.2";
    hash = lib.fakeSha256;
    meta.description = "Industrial strength alternative to OCaml's standard library";
    buildInputs = [ jst-config ];
    propagatedBuildInputs = [ base base_bigstring base_quickcheck ppx_jane time_now ];
    doCheck = false; # circular dependency with core_kernel
  };

  core_bench = janePackage {
    pname = "core_bench";
    hash = lib.fakeSha256;
    meta.description = "Benchmarking library";
    propagatedBuildInputs = [ textutils ];
  };

  core_extended = janePackage {
    pname = "core_extended";
    hash = lib.fakeSha256;
    meta.description = "Extra components that are not as closely vetted or as stable as Core";
    propagatedBuildInputs = [ core_unix record_builder ];
  };

  core_kernel = janePackage {
    pname = "core_kernel";
    hash = lib.fakeSha256;
    meta.description = "System-independent part of Core";
    buildInputs = [ jst-config ];
    propagatedBuildInputs = [ base_bigstring core int_repr sexplib ];
    doCheck = false; # we don't have quickcheck_deprecated
  };

  core_unix = janePackage {
    pname = "core_unix";
    hash = lib.fakeSha256;
    meta.description = "Unix-specific portions of Core";
    buildInputs = [ jst-config ];
    propagatedBuildInputs = [ core_kernel expect_test_helpers_core ocaml_intrinsics ppx_jane timezone spawn ];
    postPatch = ''
      patchShebangs unix_pseudo_terminal/src/discover.sh
    '';
  };

  csvfields = janePackage {
    pname = "csvfields";
    hash = lib.fakeSha256;
    propagatedBuildInputs = [ core num ];
    meta.description = "Runtime support for ppx_xml_conv and ppx_csv_conv";
  };

  dedent = janePackage {
    pname = "dedent";
    hash = lib.fakeSha256;
    propagatedBuildInputs = [ base ppx_jane stdio ];
    meta.description = "A library for improving redability of multi-line string constants in code";
  };

  delimited_parsing = janePackage {
    pname = "delimited_parsing";
    hash = lib.fakeSha256;
    propagatedBuildInputs = [ async core_extended ];
    meta.description = "Parsing of character (e.g., comma) separated and fixed-width values";
  };

  diffable = janePackage {
    pname = "diffable";
    hash = lib.fakeSha256;
    propagatedBuildInputs = [ core ppx_jane stored_reversed streamable ];
    meta.description = "An interface for diffs";
  };

  ecaml = janePackage {
    pname = "ecaml";
    hash = lib.fakeSha256;
    meta.description = "Library for writing Emacs plugin in OCaml";
    propagatedBuildInputs = [ async expect_test_helpers_core ];
  };

  email_message = janePackage {
    pname = "email_message";
    hash = lib.fakeSha256;
    meta.description = "E-mail message parser";
    propagatedBuildInputs = [ angstrom async base64 cryptokit magic-mime re2 ];
  };

  env_config = janePackage {
    pname = "env_config";
    hash = lib.fakeSha256;
    meta.description = "Helper library for retrieving configuration from an environment variable";
    propagatedBuildInputs = [ async core core_unix ppx_jane ];
  };

  expect_test_helpers_async = janePackage {
    pname = "expect_test_helpers_async";
    hash = lib.fakeSha256;
    meta.description = "Async helpers for writing expectation tests";
    propagatedBuildInputs = [ async expect_test_helpers_core ];
  };

  expect_test_helpers_core = janePackage {
    pname = "expect_test_helpers_core";
    hash = lib.fakeSha256;
    meta.description = "Helpers for writing expectation tests";
    propagatedBuildInputs = [ core_kernel sexp_pretty ];
  };

  fieldslib = janePackage {
    pname = "fieldslib";
    hash = lib.fakeSha256;
    meta.description = "Syntax extension to define first class values representing record fields, to get and set record fields, iterate and fold over all fields of a record and create new record values";
    propagatedBuildInputs = [ base ];
  };

  file_path = janePackage {
    pname = "file_path";
    hash = lib.fakeSha256;
    meta.description =
      "A library for typed manipulation of UNIX-style file paths";
    propagatedBuildInputs = [
      async
      core
      core_kernel
      core_unix
      expect_test_helpers_async
      expect_test_helpers_core
      ppx_jane
    ];
  };

  fuzzy_match = janePackage {
    pname = "fuzzy_match";
    hash = lib.fakeSha256;
    meta.description = "A library for fuzzy string matching";
    propagatedBuildInputs = [ core ppx_jane ];
  };

  fzf = janePackage {
    pname = "fzf";
    hash = lib.fakeSha256;
    meta.description = "A library for running the fzf command line tool";
    propagatedBuildInputs = [ async core_kernel ppx_jane ];
    postPatch = ''
      substituteInPlace src/fzf.ml --replace /usr/bin/fzf ${fzf}/bin/fzf
    '';
  };

  hex_encode = janePackage {
    pname = "hex_encode";
    hash = lib.fakeSha256;
    meta.description = "Hexadecimal encoding library";
    propagatedBuildInputs = [ core ppx_jane ounit ];
  };

  higher_kinded = janePackage {
    pname = "higher_kinded";
    hash = lib.fakeSha256;
    meta.description = "A library with an encoding of higher kinded types in OCaml";
    propagatedBuildInputs = [ base ppx_jane ];
  };

  incr_dom = janePackage {
    pname = "incr_dom";
    hash = lib.fakeSha256;
    meta.description = "A library for building dynamic webapps, using Js_of_ocaml";
    buildInputs = [ js_of_ocaml-ppx ];
    propagatedBuildInputs = [ async_js incr_map incr_select virtual_dom ];
  };

  incr_map = janePackage {
    pname = "incr_map";
    hash = lib.fakeSha256;
    meta.description = "Helpers for incremental operations on map like data structures";
    buildInputs = [ ppx_pattern_bind ];
    propagatedBuildInputs = [ abstract_algebra bignum diffable incremental streamable ];
  };

  incr_select = janePackage {
    pname = "incr_select";
    hash = lib.fakeSha256;
    meta.description = "Handling of large set of incremental outputs from a single input";
    propagatedBuildInputs = [ incremental ];
  };

  incremental = janePackage {
    pname = "incremental";
    hash = lib.fakeSha256;
    meta.description = "Library for incremental computations";
    propagatedBuildInputs = [ core_kernel lru_cache ];
  };

  indentation_buffer = janePackage {
    pname = "indentation_buffer";
    hash = lib.fakeSha256;
    meta.description = "A library for building strings with indentation";
    propagatedBuildInputs = [ core ppx_jane ];
  };

  int_repr = janePackage {
    pname = "int_repr";
    hash = lib.fakeSha256;
    meta.description = "Integers of various widths";
    propagatedBuildInputs = [ base ppx_jane ];
  };

  janestreet_cpuid = janePackage {
    pname = "janestreet_cpuid";
    hash = lib.fakeSha256;
    meta.description = "A library for parsing CPU capabilities out of the `cpuid` instruction";
    propagatedBuildInputs = [ core core_kernel ppx_jane ];
  };

  janestreet_csv = janePackage {
    pname = "janestreet_csv";
    hash = lib.fakeSha256;
    propagatedBuildInputs = [ async bignum core_kernel core_unix csvfields delimited_parsing fieldslib numeric_string ppx_jane re2 textutils tyxml ocaml_pcre ];
    meta.description = "Tools for working with CSVs on the command line";
  };

  jane_rope = janePackage {
    pname = "jane_rope";
    hash = lib.fakeSha256;
    meta.description = "String representation with cheap concatenation";
    propagatedBuildInputs = [ base ppx_jane ];
  };

  jane-street-headers = janePackage {
    pname = "jane-street-headers";
    hash = lib.fakeSha256;
    meta.description = "Jane Street C header files";
  };

  js_of_ocaml_patches = janePackage {
    pname = "js_of_ocaml_patches";
    hash = lib.fakeSha256;
    meta.description = "Additions to js_of_ocaml's standard library that are required by Jane Street libraries";
    propagatedBuildInputs = [ js_of_ocaml js_of_ocaml-ppx ];
  };

  jsonaf = janePackage {
    pname = "jsonaf";
    hash = lib.fakeSha256;
    meta.description = "A library for parsing, manipulating, and serializing data structured as JSON";
    propagatedBuildInputs = [ base ppx_jane angstrom faraday ];
  };

  jst-config = janePackage {
    pname = "jst-config";
    hash = lib.fakeSha256;
    meta.description = "Compile-time configuration for Jane Street libraries";
    buildInputs = [ dune-configurator ppx_assert stdio ];
  };

  krb = janePackage {
    pname = "krb";
    hash = lib.fakeSha256;
    meta.description = "A library for using Kerberos for both Rpc and Tcp communication";
    propagatedBuildInputs = [ async base core env_config hex_encode ppx_jane protocol_version_header username_kernel dune-configurator krb5 ];
  };

  lru_cache = janePackage {
    pname = "lru_cache";
    hash = lib.fakeSha256;
    meta.description = "An LRU Cache implementation";
    propagatedBuildInputs = [ core_kernel ppx_jane ];
  };

  man_in_the_middle_debugger = janePackage {
    pname = "man_in_the_middle_debugger";
    hash = lib.fakeSha256;
    meta.description = "Man-in-the-middle debugging library";
    propagatedBuildInputs = [ async core ppx_jane angstrom angstrom-async ];
  };

  n_ary = janePackage {
    pname = "n_ary";
    hash = lib.fakeSha256;
    meta.description = "A library for N-ary datatypes and operations";
    propagatedBuildInputs = [ base expect_test_helpers_core ppx_compare ppx_enumerate ppx_hash ppx_jane ppx_sexp_conv ppx_sexp_message ];
  };

  numeric_string = janePackage {
    pname = "numeric_string";
    hash = lib.fakeSha256;
    meta.description = "A comparison function for strings that sorts numeric fragments of strings according to their numeric value";
    propagatedBuildInputs = [ base ppx_jane ];
  };

  ocaml-compiler-libs = janePackage ({
    pname = "ocaml-compiler-libs";
    minimalOCamlVersion = "4.04.1";
    meta.description = "OCaml compiler libraries repackaged";
  } // (if lib.versionAtLeast ocaml.version "5.2" then {
    version = "0.17.0";
    hash = lib.fakeSha256;
  } else {
    version = "0.12.4";
    hash = lib.fakeSha256;
  }));

  ocaml-embed-file = janePackage {
    pname = "ocaml-embed-file";
    hash = lib.fakeSha256;
    propagatedBuildInputs = [ async ppx_jane ];
    meta.description = "Files contents as module constants";
  };

  ocaml_intrinsics = janePackage {
    pname = "ocaml_intrinsics";
    hash = lib.fakeSha256;
    meta.description = "Intrinsics";
    buildInputs = [ dune-configurator ];
    doCheck = false; # test rules broken
  };

  of_json = janePackage {
    pname = "of_json";
    hash = lib.fakeSha256;
    meta.description = "A friendly applicative interface for Jsonaf";
    buildInputs = [ core core_extended jsonaf ppx_jane ];
  };

  ordinal_abbreviation = janePackage {
    pname = "ordinal_abbreviation";
    hash = lib.fakeSha256;
    meta.description = "A minimal library for generating ordinal names of integers";
    buildInputs = [ base ppx_jane ];
  };

  parsexp = janePackage {
    pname = "parsexp";
    hash = lib.fakeSha256;
    meta.description = "S-expression parsing library";
    propagatedBuildInputs = [ base sexplib0 ];
  };

  patdiff = janePackage {
    pname = "patdiff";
    hash = lib.fakeSha256;

    # Used by patdiff-git-wrapper.  Providing it here also causes the shebang
    # line to be automatically patched.
    buildInputs = [ bash ];
    propagatedBuildInputs = [ core_unix patience_diff ocaml_pcre ];
    meta = {
      description = "File Diff using the Patience Diff algorithm";
    };
  };

  patience_diff = janePackage {
    pname = "patience_diff";
    hash = lib.fakeSha256;
    meta.description = "Diff library using Bram Cohen's patience diff algorithm";
    propagatedBuildInputs = [ core_kernel ];
  };

  polling_state_rpc = janePackage {
    pname = "polling_state_rpc";
    hash = lib.fakeSha256;
    meta.description = "An RPC which tracks state on the client and server so it only needs to send diffs across the wire";
    propagatedBuildInputs = [ async_kernel async_rpc_kernel core core_kernel diffable ppx_jane ];
  };

  posixat = janePackage {
    pname = "posixat";
    hash = lib.fakeSha256;
    propagatedBuildInputs = [ ppx_optcomp ppx_sexp_conv ];
    meta.description = "Binding to the posix *at functions";
  };

  ppx_accessor = janePackage {
    version = "0.16.1";
    pname = "ppx_accessor";
    hash = lib.fakeSha256;
    meta.description = "[@@deriving] plugin to generate accessors for use with the Accessor libraries";
    propagatedBuildInputs = [ accessor ];
  };

  ppx_assert = janePackage {
    pname = "ppx_assert";
    hash = lib.fakeSha256;
    meta.description = "Assert-like extension nodes that raise useful errors on failure";
    propagatedBuildInputs = [ ppx_cold ppx_compare ppx_here ppx_sexp_conv ];
  };

  ppx_base = janePackage {
    pname = "ppx_base";
    hash = lib.fakeSha256;
    meta.description = "Base set of ppx rewriters";
    propagatedBuildInputs = [ ppx_cold ppx_enumerate ppx_globalize ppx_hash ];
  };

  ppx_bench = janePackage {
    pname = "ppx_bench";
    hash = lib.fakeSha256;
    meta.description = "Syntax extension for writing in-line benchmarks in ocaml code";
    propagatedBuildInputs = [ ppx_inline_test ];
  };

  ppx_bin_prot = janePackage {
    pname = "ppx_bin_prot";
    hash = lib.fakeSha256;
    meta.description = "Generation of bin_prot readers and writers from types";
    propagatedBuildInputs = [ bin_prot ppx_here ];
    doCheck = false; # circular dependency with ppx_jane
  };

  ppx_cold = janePackage {
    pname = "ppx_cold";
    hash = lib.fakeSha256;
    meta.description = "Expands [@cold] into [@inline never][@specialise never][@local never]";
    propagatedBuildInputs = [ ppxlib ];
  };

  ppx_compare = janePackage {
    pname = "ppx_compare";
    hash = lib.fakeSha256;
    meta.description = "Generation of comparison functions from types";
    propagatedBuildInputs = [ ppxlib base ];
  };

  ppx_conv_func = janePackage {
    pname = "ppx_conv_func";
    hash = lib.fakeSha256;
    meta.description = "Part of the Jane Street's PPX rewriters collection";
    propagatedBuildInputs = [ ppxlib base ];
  };

  ppx_custom_printf = janePackage {
    pname = "ppx_custom_printf";
    hash = lib.fakeSha256;
    meta.description = "Printf-style format-strings for user-defined string conversion";
    propagatedBuildInputs = [ ppx_sexp_conv ];
  };

  ppx_css = janePackage {
    pname = "ppx_css";
    hash = lib.fakeSha256;
    meta.description = "A ppx that takes in css strings and produces a module for accessing the unique names defined within";
    propagatedBuildInputs = [ async async_unix core_kernel core_unix ppxlib js_of_ocaml js_of_ocaml-ppx sedlex virtual_dom ];
  };

  ppx_csv_conv = janePackage {
    pname = "ppx_csv_conv";
    hash = lib.fakeSha256;
    meta.description = "Generate functions to read/write records in csv format";
    propagatedBuildInputs = [ csvfields ppx_conv_func ];
  };

  ppx_demo = janePackage {
    pname = "ppx_demo";
    hash = lib.fakeSha256;
    meta.description = "PPX that exposes the source code string of an expression/module structure";
    propagatedBuildInputs = [ core dedent ppx_jane ppxlib ];
  };

  ppx_derive_at_runtime = janePackage {
    pname = "ppx_derive_at_runtime";
    hash = lib.fakeSha256;
    meta.description = "Define a new ppx deriver by naming a runtime module";
    propagatedBuildInputs = [ base expect_test_helpers_core ppx_jane ppxlib ];
  };

  ppx_disable_unused_warnings = janePackage {
    pname = "ppx_disable_unused_warnings";
    hash = lib.fakeSha256;
    meta.description = "Expands [@disable_unused_warnings] into [@warning \"-20-26-32-33-34-35-36-37-38-39-60-66-67\"]";
    propagatedBuildInputs = [ ppxlib ];
  };

  ppx_enumerate = janePackage {
    pname = "ppx_enumerate";
    hash = lib.fakeSha256;
    meta.description = "Generate a list containing all values of a finite type";
    propagatedBuildInputs = [ ppxlib ];
  };

  ppx_expect = janePackage {
    pname = "ppx_expect";
    hash = lib.fakeSha256;
    meta.description = "Cram like framework for OCaml";
    propagatedBuildInputs = [ ppx_here ppx_inline_test re ];
    doCheck = false; # test build rules broken
  };

  ppx_fields_conv = janePackage {
    pname = "ppx_fields_conv";
    hash = lib.fakeSha256;
    meta.description = "Generation of accessor and iteration functions for ocaml records";
    propagatedBuildInputs = [ fieldslib ppxlib ];
  };

  ppx_fixed_literal = janePackage {
    pname = "ppx_fixed_literal";
    hash = lib.fakeSha256;
    meta.description = "Simpler notation for fixed point literals";
    propagatedBuildInputs = [ ppxlib ];
  };

  ppx_globalize = janePackage {
    pname = "ppx_globalize";
    hash = lib.fakeSha256;
    meta.description = "A ppx rewriter that generates functions to copy local values to the global heap";
    propagatedBuildInputs = [ base ppxlib ];
  };

  ppx_hash = janePackage {
    pname = "ppx_hash";
    hash = lib.fakeSha256;
    meta.description = "A ppx rewriter that generates hash functions from type expressions and definitions";
    propagatedBuildInputs = [ ppx_compare ppx_sexp_conv ];
  };

  ppx_here = janePackage {
    pname = "ppx_here";
    hash = lib.fakeSha256;
    meta.description = "Expands [%here] into its location";
    propagatedBuildInputs = [ ppxlib ];
    doCheck = false; # test build rules broken
  };

  ppx_ignore_instrumentation = janePackage {
    pname = "ppx_ignore_instrumentation";
    hash = lib.fakeSha256;
    meta.description = "Ignore Jane Street specific instrumentation extensions";
    propagatedBuildInputs = [ ppxlib ];
  };

  ppx_inline_test = janePackage {
    pname = "ppx_inline_test";
    hash = lib.fakeSha256;
    meta.description = "Syntax extension for writing in-line tests in ocaml code";
    propagatedBuildInputs = [ ppxlib time_now ];
    doCheck = false; # test build rules broken
  };

  ppx_jane = janePackage {
    pname = "ppx_jane";
    hash = lib.fakeSha256;
    meta.description = "Standard Jane Street ppx rewriters";
    propagatedBuildInputs = [ base_quickcheck ppx_bin_prot ppx_disable_unused_warnings ppx_expect ppx_fixed_literal ppx_ignore_instrumentation ppx_log ppx_module_timer ppx_optcomp ppx_optional ppx_pipebang ppx_stable ppx_string ppx_tydi ppx_typerep_conv ppx_variants_conv ];
  };

  ppx_jsonaf_conv = janePackage {
    pname = "ppx_jsonaf_conv";
    hash = lib.fakeSha256;
    meta.description =
      "[@@deriving] plugin to generate Jsonaf conversion functions";
    propagatedBuildInputs = [ base jsonaf ppx_jane ppxlib ];
  };

  ppx_js_style = janePackage {
    pname = "ppx_js_style";
    hash = lib.fakeSha256;
    meta.description = "Code style checker for Jane Street Packages";
    propagatedBuildInputs = [ octavius ppxlib ];
  };

  ppx_let = janePackage {
    pname = "ppx_let";
    hash = lib.fakeSha256;
    meta.description = "Monadic let-bindings";
    propagatedBuildInputs = [ ppxlib ppx_here ];
  };

  ppx_log = janePackage {
    pname = "ppx_log";
    hash = lib.fakeSha256;
    meta.description = "Ppx_sexp_message-like extension nodes for lazily rendering log messages";
    propagatedBuildInputs = [ base ppx_here ppx_sexp_conv ppx_sexp_message sexplib ];
  };

  ppx_module_timer = janePackage {
    pname = "ppx_module_timer";
    hash = lib.fakeSha256;
    meta.description = "Ppx rewriter that records top-level module startup times";
    propagatedBuildInputs = [ time_now ];
  };

  ppx_optcomp = janePackage {
    pname = "ppx_optcomp";
    hash = lib.fakeSha256;
    meta.description = "Optional compilation for OCaml";
    propagatedBuildInputs = [ ppxlib ];
  };

  ppx_optional = janePackage {
    pname = "ppx_optional";
    hash = lib.fakeSha256;
    meta.description = "Pattern matching on flat options";
    propagatedBuildInputs = [ ppxlib ];
  };

  ppx_pattern_bind = janePackage {
    pname = "ppx_pattern_bind";
    hash = lib.fakeSha256;
    meta.description = "A ppx for writing fast incremental bind nodes in a pattern match";
    propagatedBuildInputs = [ ppx_let ];
  };

  ppx_pipebang = janePackage {
    pname = "ppx_pipebang";
    hash = lib.fakeSha256;
    meta.description = "A ppx rewriter that inlines reverse application operators `|>` and `|!`";
    propagatedBuildInputs = [ ppxlib ];
  };

  ppx_python = janePackage {
    pname = "ppx_python";
    hash = lib.fakeSha256;
    meta.description = "A [@@deriving] plugin to generate Python conversion functions ";
    propagatedBuildInputs = [ ppx_base ppxlib pyml ];
  };

  ppx_sexp_conv = janePackage {
    pname = "ppx_sexp_conv";
    hash = lib.fakeSha256;
    meta.description = "[@@deriving] plugin to generate S-expression conversion functions";
    propagatedBuildInputs = [ ppxlib sexplib0 base ];
  };

  ppx_sexp_message = janePackage {
    pname = "ppx_sexp_message";
    hash = lib.fakeSha256;
    meta.description = "A ppx rewriter for easy construction of s-expressions";
    propagatedBuildInputs = [ ppx_here ppx_sexp_conv ];
  };

  ppx_sexp_value = janePackage {
    pname = "ppx_sexp_value";
    hash = lib.fakeSha256;
    meta.description = "A ppx rewriter that simplifies building s-expressions from ocaml values";
    propagatedBuildInputs = [ ppx_here ppx_sexp_conv ];
  };

  ppx_stable = janePackage {
    pname = "ppx_stable";
    hash = lib.fakeSha256;
    meta.description = "Stable types conversions generator";
    propagatedBuildInputs = [ ppxlib ];
  };

  ppx_stable_witness = janePackage {
    pname = "ppx_stable_witness";
    hash = lib.fakeSha256;
    meta.description = "Ppx extension for deriving a witness that a type is intended to be stable";
    propagatedBuildInputs = [ base ppxlib ];
  };

  ppx_string = janePackage {
    pname = "ppx_string";
    hash = lib.fakeSha256;
    meta.description = "Ppx extension for string interpolation";
    propagatedBuildInputs = [ ppx_base ppxlib stdio ];
  };

  ppx_tydi = janePackage {
    pname = "ppx_tydi";
    hash = lib.fakeSha256;
    meta.description = "Let expressions, inferring pattern type from expression";
    propagatedBuildInputs = [ base ppxlib ];
  };

  ppx_typed_fields = janePackage {
    pname = "ppx_typed_fields";
    hash = lib.fakeSha256;
    meta.description = "GADT-based field accessors and utilities";
    propagatedBuildInputs = [ core ppx_jane ppxlib ];
  };

  ppx_typerep_conv = janePackage {
    pname = "ppx_typerep_conv";
    hash = lib.fakeSha256;
    meta.description = "Generation of runtime types from type declarations";
    propagatedBuildInputs = [ ppxlib typerep ];
  };

  ppx_variants_conv = janePackage {
    pname = "ppx_variants_conv";
    hash = lib.fakeSha256;
    meta.description = "Generation of accessor and iteration functions for ocaml variant types";
    propagatedBuildInputs = [ variantslib ppxlib ];
  };

  pythonlib = janePackage {
    pname = "pythonlib";
    version = "0.16";
    hash = lib.fakeSha256;
    meta.description = "A library to help writing wrappers around ocaml code for python";
    propagatedBuildInputs = [ base core expect_test_helpers_core ppx_compare ppx_expect ppx_here ppx_let ppx_python ppx_string stdio typerep pyml ];
    meta.broken = lib.versionAtLeast ocaml.version "4.14";
  };

  profunctor = janePackage {
    pname = "profunctor";
    hash = lib.fakeSha256;
    meta.description = "A library providing a signature for simple profunctors and traversal of a record";
    propagatedBuildInputs = [ base ppx_jane record_builder ];
  };

  protocol_version_header = janePackage {
    pname = "protocol_version_header";
    hash = lib.fakeSha256;
    meta.description = "Protocol versioning";
    propagatedBuildInputs = [ core_kernel ];
  };

  re2 = janePackage {
    pname = "re2";
    hash = lib.fakeSha256;
    meta.description = "OCaml bindings for RE2, Google's regular expression library";
    propagatedBuildInputs = [ core_kernel jane_rope regex_parser_intf ];
    prePatch = ''
      substituteInPlace src/re2_c/dune --replace 'CXX=g++' 'CXX=c++'
      substituteInPlace src/dune --replace '(cxx_flags (:standard \ -pedantic) (-I re2_c/libre2))' '(cxx_flags (:standard \ -pedantic) (-I re2_c/libre2) (-x c++))'
    '';
  };

  re2_stable = janePackage {
    pname = "re2_stable";
    version = "0.14.0";
    hash = lib.fakeSha256;
    meta.description = "Re2_stable adds an incomplete but stable serialization of Re2";
    propagatedBuildInputs = [ core re2 ];
  };

  record_builder = janePackage {
    pname = "record_builder";
    hash = lib.fakeSha256;
    meta.description = "A library which provides traversal of records with an applicative";
    propagatedBuildInputs = [ base ppx_jane ];
  };

  redis-async = janePackage {
    pname = "redis-async";
    hash = lib.fakeSha256;
    meta.description = "Redis client for Async applications";
    propagatedBuildInputs = [ async bignum core core_kernel ppx_jane ];
  };

  regex_parser_intf = janePackage {
    pname = "regex_parser_intf";
    hash = lib.fakeSha256;
    meta.description = "Interface shared by Re_parser and Re2.Parser";
    propagatedBuildInputs = [ base ];
  };

  resource_cache = janePackage {
    pname = "resource_cache";
    hash = lib.fakeSha256;
    meta.description = "General resource cache";
    propagatedBuildInputs = [ async_rpc_kernel ];
  };

  semantic_version = janePackage {
    pname = "semantic_version";
    hash = lib.fakeSha256;
    meta.description = "Semantic versioning";
    propagatedBuildInputs = [ core ppx_jane re ];
  };

  sexp = janePackage {
    pname = "sexp";
    hash = lib.fakeSha256;
    propagatedBuildInputs = [
      async
      core
      csvfields
      jsonaf
      re2
      sexp_diff
      sexp_macro
      sexp_pretty
      sexp_select
      shell
    ];
    meta.description = "S-expression swiss knife";
  };

  sexp_grammar = janePackage {
    pname = "sexp_grammar";
    hash = lib.fakeSha256;
    propagatedBuildInputs = [ core ppx_bin_prot ppx_compare ppx_hash ppx_let ppx_sexp_conv ppx_sexp_message zarith ];
    meta.description = "Helpers for manipulating [Sexplib.Sexp_grammar] values";
  };

  sexp_diff = janePackage {
    pname = "sexp_diff";
    hash = lib.fakeSha256;
    propagatedBuildInputs = [ core_kernel ];
    meta.description = "Code for computing the diff of two sexps";
  };

  sexp_macro = janePackage {
    pname = "sexp_macro";
    hash = lib.fakeSha256;
    propagatedBuildInputs = [ async sexplib ];
    meta.description = "Sexp macros";
  };

  sexp_pretty = janePackage {
    pname = "sexp_pretty";
    hash = lib.fakeSha256;
    meta.description = "S-expression pretty-printer";
    propagatedBuildInputs = [ ppx_base re sexplib ];
  };

  sexp_select = janePackage {
    pname = "sexp_select";
    hash = lib.fakeSha256;
    propagatedBuildInputs = [ base ppx_jane ];
    meta.description = "A library to use CSS-style selectors to traverse sexp trees";
  };

  sexplib0 = janePackage {
    pname = "sexplib0";
    hash = lib.fakeSha256;
    minimalOCamlVersion = "4.08.0";
    meta.description = "Library containing the definition of S-expressions and some base converters";
  };

  sexplib = janePackage {
    pname = "sexplib";
    hash = lib.fakeSha256;
    meta.description = "Library for serializing OCaml values to and from S-expressions";
    propagatedBuildInputs = [ num parsexp ];
  };

  shell = janePackage {
    pname = "shell";
    hash = lib.fakeSha256;
    meta.description = "Yet another implementation of fork&exec and related functionality";
    buildInputs = [ jst-config ];
    propagatedBuildInputs = [ textutils ];
    checkInputs = [ ounit ];
  };

  shexp = janePackage {
    pname = "shexp";
    hash = lib.fakeSha256;
    propagatedBuildInputs = [ posixat spawn ];
    meta.description = "Process library and s-expression based shell";
  };

  spawn = janePackage {
    pname = "spawn";
    minimalOCamlVersion = "4.02.3";
    version = "0.15.0";
    hash = lib.fakeSha256;
    meta.description = "Spawning sub-processes";
    buildInputs = [ ppx_expect ];
  };

  splay_tree = janePackage {
    pname = "splay_tree";
    hash = lib.fakeSha256;
    meta.description = "A splay tree implementation";
    propagatedBuildInputs = [ core_kernel ];
  };

  splittable_random = janePackage {
    pname = "splittable_random";
    hash = lib.fakeSha256;
    meta.description = "PRNG that can be split into independent streams";
    propagatedBuildInputs = [ base ppx_assert ppx_bench ppx_sexp_message ];
  };

  stdio = janePackage {
    pname = "stdio";
    hash = lib.fakeSha256;
    meta.description = "Standard IO library for OCaml";
    propagatedBuildInputs = [ base ];
  };

  stored_reversed = janePackage {
    pname = "stored_reversed";
    hash = lib.fakeSha256;
    meta.description = "A library for representing a list temporarily stored in reverse order";
    propagatedBuildInputs = [ core ppx_jane ];
  };

  streamable = janePackage {
    version = "0.16.1";
    pname = "streamable";
    hash = lib.fakeSha256;
    meta.description = "A collection of types suitable for incremental serialization";
    propagatedBuildInputs = [ async_kernel async_rpc_kernel base core core_kernel ppx_jane ppxlib ];
  };

  textutils = janePackage {
    pname = "textutils";
    hash = lib.fakeSha256;
    meta.description = "Text output utilities";
    propagatedBuildInputs = [ core_unix textutils_kernel ];
  };

  textutils_kernel = janePackage {
    pname = "textutils_kernel";
    hash = lib.fakeSha256;
    meta.description = "Text output utilities";
    propagatedBuildInputs = [ core ppx_jane uutf ];
  };

  tilde_f = janePackage {
    pname = "tilde_f";
    hash = lib.fakeSha256;
    meta.description = "Provides a let-syntax for continuation-passing style";
    propagatedBuildInputs = [ base ppx_jane ];
  };

  time_now = janePackage {
    pname = "time_now";
    hash = lib.fakeSha256;
    meta.description = "Reports the current time";
    buildInputs = [ jst-config ppx_optcomp ];
    propagatedBuildInputs = [ jane-street-headers base ppx_base ];
  };

  timezone = janePackage {
    pname = "timezone";
    hash = lib.fakeSha256;
    meta.description = "Time-zone handling";
    propagatedBuildInputs = [ core_kernel ];
  };

  topological_sort = janePackage {
    pname = "topological_sort";
    hash = lib.fakeSha256;
    meta.description = "Topological sort algorithm";
    propagatedBuildInputs = [ ppx_jane stdio ];
  };

  typerep = janePackage {
    pname = "typerep";
    hash = lib.fakeSha256;
    meta.description = "Typerep is a library for runtime types";
    propagatedBuildInputs = [ base ];
  };

  username_kernel = janePackage {
    pname = "username_kernel";
    hash = lib.fakeSha256;
    meta.description = "An identifier for a user";
    propagatedBuildInputs = [ core ppx_jane ];
  };

  variantslib = janePackage {
    pname = "variantslib";
    hash = lib.fakeSha256;
    meta.description = "Part of Jane Street's Core library";
    propagatedBuildInputs = [ base ];
  };

  vcaml = janePackage {
    pname = "vcaml";
    hash = lib.fakeSha256;
    meta.description = "OCaml bindings for the Neovim API";
    propagatedBuildInputs = [ angstrom-async async_extra expect_test_helpers_async faraday jsonaf man_in_the_middle_debugger semantic_version ];
    patches = [ ./vcaml.patch ];
  };

  virtual_dom = janePackage {
    pname = "virtual_dom";
    hash = lib.fakeSha256;
    meta.description = "OCaml bindings for the virtual-dom library";
    buildInputs = [ js_of_ocaml-ppx ];
    propagatedBuildInputs = [ base64 core_kernel gen_js_api js_of_ocaml js_of_ocaml_patches lambdasoup tyxml uri ];
  };

  zarith_stubs_js = janePackage {
    pname = "zarith_stubs_js";
    hash = lib.fakeSha256;
    meta.description = "Javascripts stubs for the Zarith library";
  };

  zstandard = janePackage {
    pname = "zstandard";
    hash = lib.fakeSha256;
    meta.description = "OCaml bindings to Zstandard";
    buildInputs = [ ppx_jane ];
    propagatedBuildInputs = [ core_kernel ctypes zstd ];
  };

}
