# Jane Street libraries as packaged for OxCaml.
#
# Jane Street has not released v0.18 -- the latest tag across these repos is
# v0.17.3 -- so every package here is pinned to a commit on its upstream
# `oxcaml` branch. The revisions are exactly those of
# oxcaml/opam-repository's v0.18~preview.130.106+341 package set and all share a
# commit date of 2026-07-10, hence the 0.18.0-unstable-2026-07-10 version string
# in janePackage_0_18_oxcaml.nix.
#
# This set replaces the v0.17 janeStreet definitions in the OxCaml scope; see
# pkgs/development/ocaml-modules/oxcaml/overrides.nix.
{
  self,
  lib,
  patchesFor,
}:

with self;

{
  abstract_algebra = janePackage {
    pname = "abstract_algebra";
    rev = "c4494f49e9c21b81aa1a85e020ccd74054d29b57";
    hash = "sha256-YF7MivuY4IqmnGaSih3ajkWaEJOnPZTtmjxRlIjkz5g=";
    meta.description = "Small library describing abstract algebra concepts";
    propagatedBuildInputs = [
      base
      ppx_jane
    ];
  };

  async = janePackage {
    pname = "async";
    rev = "5c1c47bb66487f536ff4c3927ffdb0448636bb48";
    hash = "sha256-mZyxR8pS6H77RpIME2MX+DP3SgyA8CNSb01S/k2H7ys=";
    meta.description = "Monadic concurrency library";
    doCheck = false;
    propagatedBuildInputs = [
      async_kernel
      async_log
      async_rpc_kernel
      async_unix
      core
      core_kernel
      core_unix
      ppx_expect
      ppx_jane
      textutils
    ];
  };

  async_js = janePackage {
    pname = "async_js";
    rev = "0e65806905bfd6c8fe31bc7ddd9e81a431d32d2a";
    hash = "sha256-9sc9gVhhiAnIFVUou9aOIxjAt+ZjfNyNvHWuJuCef28=";
    meta.description = "Small library that provide Async support for JavaScript platforms";
    # The cram test runs the compiled JS under `node`, which is not available in
    # the build sandbox.
    doCheck = false;
    propagatedBuildInputs = [
      async_kernel
      async_rpc_kernel
      core
      js_of_ocaml
      js_of_ocaml-ppx
      ppx_expect
      ppx_jane
      uri
      uri-sexp
    ];
  };

  async_kernel = janePackage {
    pname = "async_kernel";
    rev = "69bd328f770d136faaf377622f84ae48d14a043c";
    hash = "sha256-o4RApPX0tVmLQO11oGmZp8XfsT/+BC3dgJRNt5TqVRM=";
    meta.description = "Monadic concurrency library";
    propagatedBuildInputs = [
      core
      core_kernel
      core_unix
      parsexp
      ppx_jane
      sexplib
      unique
    ];
  };

  async_log = janePackage {
    pname = "async_log";
    rev = "ff6ecfae4f8479bb96b8c1159f62d7d321849f1d";
    hash = "sha256-3FzWnvmoiy7Wa4x6afAWaUX6sH3RL2SkN7H38DDD38c=";
    meta.description = "Logging library built on top of Async_unix";
    propagatedBuildInputs = [
      async_kernel
      async_unix
      core
      core_kernel
      core_unix
      ppx_jane
    ];
  };

  async_rpc_kernel = janePackage {
    pname = "async_rpc_kernel";
    rev = "4ef0e7b7262c0576cc9a58f0ad3da3bb6a633c63";
    hash = "sha256-ZTlIlxYXo4vXDFWKbDoh5WP1Z7tQriEuXnXZt25uhQw=";
    meta.description = "Platform-independent core of Async RPC library";
    propagatedBuildInputs = [
      async_kernel
      bin_prot
      core
      core_extended
      core_kernel
      flexible_sexp
      pipe_with_writer_error
      ppx_jane
      protocol_version_header
      sexplib
    ];
  };

  async_unix = janePackage {
    pname = "async_unix";
    rev = "f2246763dc308b12dc2ac84820117b1ef07e4879";
    hash = "sha256-785gJZ8ON3dCGhXY8FJTTDG4JJG462mZ4C1QmHIxfdc=";
    meta.description = "Monadic concurrency library";
    propagatedBuildInputs = [
      async_kernel
      core
      core_kernel
      core_unix
      cstruct
      ppx_jane
      ppx_optcomp
      sexplib
    ];
  };

  base = janePackage {
    pname = "base";
    rev = "858a66ad1768e4b9d76fa7d19a1afbd74fa8a3e4";
    hash = "sha256-3uTGKI7s+s8utqRmf0zMwVmZP512uUnPPtVCjxO4bPg=";
    meta.description = "Full standard library replacement for OCaml";
    propagatedBuildInputs = [
      base_internalhash_types
      basement
      capsule0
      nonempty_list_type
      ocaml_intrinsics_kernel
      ppx_array_base
      ppx_base
      ppxlib_jane
      sexplib0
    ];
    buildInputs = [
      dune-configurator
      ppxlib
    ];
  };

  base_bigstring = janePackage {
    pname = "base_bigstring";
    rev = "3ab6b8cafa1dec4846835d3924d83afce05ff55e";
    hash = "sha256-tnhD+/7N7+DS1WH4FWGaEl1ybOeX0a21Uu9xfjpy6rg=";
    meta.description = "String type based on [Bigarray], for use in I/O and C-bindings";
    propagatedBuildInputs = [
      base
      int_repr
      ppx_jane
      sexplib
    ];
  };

  base_internalhash_types = janePackage {
    pname = "base_internalhash_types";
    rev = "e030c5a8bc85274bd0aaf299bd90ea1790e42ec5";
    hash = "sha256-m5AiDEqGdh3QOtFvV3CKPMgd5RUfhanYc+0aDDEvOUk=";
    meta.description = "Types and simple helpers for building up hash functions";
  };

  base_quickcheck = janePackage {
    pname = "base_quickcheck";
    rev = "0f1b3b9beb133b703a51788f19d7a20993b5ed4b";
    hash = "sha256-4zJiZSbP6K4QTwmMDGMreji1rzoyteUV9skT9i+9Lkc=";
    meta.description = "Randomized testing framework, designed for compatibility with Base";
    propagatedBuildInputs = [
      base
      ppx_base
      ppx_fields_conv
      ppx_helpers
      ppx_let
      ppx_portable
      ppx_sexp_message
      ppx_sexp_value
      ppx_shorthand
      ppx_template
      ppxlib_jane
      splittable_random
    ];
    buildInputs = [
      ocaml-compiler-libs
      ppxlib
    ];
  };

  basement = janePackage {
    pname = "basement";
    rev = "548a0ea240342807a30fff81290db4e80c98994e";
    hash = "sha256-Am9IaYi2isVCWBX3TJHBjpnxq6ZuA7LshvaAR9ZKHKA=";
    meta.description = "Modules defined upstream of and reexported in Base";
  };

  bignum = janePackage {
    pname = "bignum";
    rev = "d359055e568906be642e54b4d98aa537d7164d00";
    hash = "sha256-mv4Y91kA3PMfHFG7CXXS3LYAYYZCgoJZDm1JVRtcmOQ=";
    meta.description = "Core-flavoured wrapper around zarith's arbitrary-precision rationals";
    # OxCaml's mode system won't coerce the global Zarith.Q.compare to a
    # local_ type, so ppx_template's `let%template[@mode local] compare =
    # compare` produces a NON-local compare__local that breaks
    # `[@@deriving compare ~localize]`. The include of Zarith.Q already
    # provides the correct local_ variants; drop the redundant templates.
    patches = [
      ./oxcaml-patches/bignum-local.patch
    ];
    propagatedBuildInputs = [
      core
      num
      ppx_jane
      ppx_stable_witness
      sexplib
      typerep
      zarith
      zarith_stubs_js
    ];
  };

  bin_prot = janePackage {
    pname = "bin_prot";
    rev = "5bf8daa91a3d76ed917ad79b211d36d77b365760";
    hash = "sha256-IHb07qd7JtjoOLDLCLJneSf25+1vYI+SeyhNh2WtW7A=";
    meta.description = "Binary protocol generator";
    propagatedBuildInputs = [
      base
      ppx_compare
      ppx_custom_printf
      ppx_fields_conv
      ppx_globalize
      ppx_optcomp
      ppx_sexp_conv
      ppx_stable_witness
      ppx_template
      ppx_variants_conv
    ];
  };

  bonsai = janePackage {
    pname = "bonsai";
    rev = "51347bc8121aa8f07f751ed77e351a3d923ef20e";
    hash = "sha256-ww2CjRpEF4OfTR2btIj6HZQ3VtdjCbsgA0TE2qr+YGA=";
    meta.description = "Library for building dynamic webapps, using Js_of_ocaml";
    doCheck = false;
    propagatedBuildInputs = [
      abstract_algebra
      async_rpc_kernel
      bonsai_concrete
      core
      core_kernel
      incr_map
      incremental
      ocaml-embed-file
      ppx_here
      ppx_jane
      ppx_let
      ppx_pattern_bind
      ppxlib_jane
      virtual_dom
      # bonsai.kernel_components.effects links js_of_ocaml, and js_of_ocaml-ppx
      # carries it as a ppx_runtime_dep, so both have to be propagated or
      # consumers fail with `Library "js_of_ocaml" not found`.
      js_of_ocaml
      js_of_ocaml-ppx
    ];
    buildInputs = [
      ppxlib
    ];
  };

  bonsai_concrete = janePackage {
    pname = "bonsai_concrete";
    rev = "645a7cfb859ec768b80b5b4ecc9973cf33383df6";
    hash = "sha256-JQocZfUeReJGdHrz6BoigOg7UcOipNHMFP0mXNZpZ6s=";
    meta.description = "Shared dependencies of bonsai and incr_dom";
    propagatedBuildInputs = [
      core
      core_kernel
      incr_map
      incr_select
      incremental
      ppx_jane
      time_now
      virtual_dom
    ];
  };

  bonsai_term = janePackage {
    pname = "bonsai_term";
    rev = "2457232d3aa144fb887a053748a920544db60f72";
    hash = "sha256-v65O+mw8t3RL8ge0wobgPRj5dnRzp9Hxvmtl5Au3wlw=";
    meta.description = "Library for building dynamic terminal apps, using bonsai";
    propagatedBuildInputs = [
      async
      bonsai
      core
      notty_async
      ppx_jane
      unboxed_datatypes
      virtual_dom
    ];
    buildInputs = [
      notty-community
    ];
  };

  bonsai_term_components = janePackage {
    pname = "bonsai_term_components";
    rev = "92760248f9d560682579bebecb2b1b773f13d13d";
    hash = "sha256-/QOm9+I2eKIQmiBsZLKGGZandMTe6KoSxy4xWkTUhYA=";
    meta.description = "Set of Terminal UI (TUI) component libraries for bonsai_term";
    propagatedBuildInputs = [
      async
      base64
      bonsai
      bonsai_concrete
      bonsai_term
      core
      core_kernel
      core_unix
      expectree
      jane_term_types
      patdiff
      pending_or_error
      ppx_delta_types
      ppx_expect
      ppx_jane
      react
      sexplib
      tmux
      vec
    ];
  };

  bonsai_term_test = janePackage {
    pname = "bonsai_term_test";
    rev = "500cd5a65e406f41f5bf8df316ce6d30656df96f";
    hash = "sha256-DK9X6i22wusbvLudccDlDTllthmZ92MCzk60FUDMzco=";
    meta.description = "Library for building dynamic terminal apps, using bonsai";
    propagatedBuildInputs = [
      async
      bonsai
      bonsai_term
      bonsai_term_components
      bonsai_test
      core
      expect_test_helpers_core
      expectable
      notty-community
      notty_async
      patdiff
      ppx_jane
      ppx_quick_test
      ppx_with
      re
    ];
  };

  bonsai_test = janePackage {
    pname = "bonsai_test";
    rev = "63f73007dd003b9af9c826c6522bfa9830e48929";
    hash = "sha256-NumPl+5c+tTw5pBy0cpLxFBXki8th2nmQ1DK4VnTdEw=";
    meta.description = "Library for testing Bonsai state machines";
    propagatedBuildInputs = [
      async
      async_js
      base
      bonsai
      bonsai_concrete
      core
      core_unix
      expect_test_helpers_base
      expect_test_helpers_core
      expectable
      incr_map
      incremental
      ocaml-embed-file
      patdiff
      ppx_expect
      ppx_jane
      ppx_pattern_bind
      ppx_quick_test
      re
      virtual_dom
    ];
  };

  capitalization = janePackage {
    pname = "capitalization";
    rev = "43553924cc40288cb8f7d2036d58386b127bd7e0";
    hash = "sha256-43weTP+iFi8IWeCtTFNum2a2GRd172nMUhgRsH88NiY=";
    meta.description = "Naming conventions for multiple-word identifiers";
    propagatedBuildInputs = [
      base
      ppx_base
    ];
    buildInputs = [
      ppxlib
    ];
  };

  capsule = janePackage {
    pname = "capsule";
    rev = "24c12e76eb299b962eefc768d6914dd9de195bbb";
    hash = "sha256-rEZn6MRP06s5GyzeF+ngMnYLMfVKdzMatDSLDkdEMh0=";
    meta.description = "Capsule api for the OxCaml mode ecosystem";
    propagatedBuildInputs = [
      base
      capsule0
      ppx_sexp_conv
      ppx_template
    ];
  };

  capsule0 = janePackage {
    pname = "capsule0";
    rev = "0a4532228d028f19c0f99f977618c7782e35f9d7";
    hash = "sha256-w01RXDiYQylJDE4mw2rzlCsgBMVdJ916tC0am2lMoQQ=";
    meta.description = "Primitive capsule api for the OxCaml mode ecosystem";
    propagatedBuildInputs = [
      basement
      ppx_template
      sexp_type
    ];
  };

  core = janePackage {
    pname = "core";
    rev = "62384b1e1e542b33c9f7c6012ecc53e66299af03";
    hash = "sha256-sXDLdRmGXF7USAE0wcwNzcj+6T82o4DkvzwmSJOGbhg=";
    meta.description = "Industrial strength alternative to OCaml's standard library";
    doCheck = false;
    propagatedBuildInputs = [
      base
      base_bigstring
      base_quickcheck
      bin_prot
      capsule
      fieldslib
      jane-street-headers
      jst-config
      parsexp
      portable
      ppx_assert
      ppx_base
      ppx_diff
      ppx_expect
      ppx_hash
      ppx_inline_test
      ppx_jane
      ppx_optcomp
      ppx_sexp_conv
      ppx_sexp_message
      ppx_stable_witness
      sexplib
      splittable_random
      stdio
      string_dict
      time_now
      typerep
      univ_map
      variantslib
    ];
  };

  core_extended = janePackage {
    pname = "core_extended";
    rev = "4ed654cd47bd1aac131a52c57fc6507635c1a923";
    hash = "sha256-Stu5Qy1JofLF42jXgnWRnJ1iuADVcfKlygABMisn/c4=";
    meta.description = "Extra components that are not as closely vetted or as stable as Core";
    propagatedBuildInputs = [
      bin_prot
      core
      core_unix
      ppx_jane
      ppx_stable_witness
      record_builder
      sexplib
      unboxed
    ];
    buildInputs = [
      re
    ];
  };

  core_kernel = janePackage {
    pname = "core_kernel";
    rev = "447e39d0bc8c5a9a52097b940a8ec86df90d10df";
    hash = "sha256-/fotv565RN05cMldiDJHauY2DJgrzrwiRlGaLciwCmE=";
    meta.description = "System-independent part of Core";
    doCheck = false;
    propagatedBuildInputs = [
      base
      bin_prot
      core
      int_repr
      parsexp
      ppx_jane
      ppx_optcomp
      ppx_sexp_conv
      ppx_stable_witness
      sexplib
      univ_map
      uopt
    ];
  };

  core_unix = janePackage {
    pname = "core_unix";
    rev = "b5b1278ac5e3cb0748fd38679ce7daa02bd9f337";
    hash = "sha256-hczjE4v4aZGQ4fhkL5xyHLUUi+rdnabLW4UIT8HDptI=";
    meta.description = "Unix-specific portions of Core";
    doCheck = false;
    # discover.sh is exec'd directly by dune and uses /usr/bin/env, which
    # doesn't exist in the nix build sandbox; patch its shebang.
    patchPhase = ''
      patchShebangs unix_pseudo_terminal/src/discover.sh
    '';
    propagatedBuildInputs = [
      base
      core
      core_kernel
      expect_test_helpers_core
      jane-street-headers
      jst-config
      ppx_builtin
      ppx_diff
      ppx_jane
      ppx_optcomp
      ppx_stable_witness
      sexplib
      spawn
    ];
  };

  expect_test_helpers_async = janePackage {
    pname = "expect_test_helpers_async";
    rev = "358d1f503f8aaa62107525694eed7961779d5509";
    hash = "sha256-Cd29x+XEkU2m4DkdxS3vowJVvD+zYApqIEZ7kat1iQ0=";
    meta.description = "Async helpers for writing expectation tests";
    propagatedBuildInputs = [
      async
      core
      core_unix
      expect_test_helpers_core
      ppx_jane
      sexp_pretty
    ];
  };

  expect_test_helpers_base = janePackage {
    pname = "expect_test_helpers_base";
    rev = "caaba6d8f791dccdd24a844a1378b27338e14a21";
    hash = "sha256-GJoUfjb5pghKvM6zPWveDBJt6GxYX2miI1HrlFoL3HU=";
    meta.description = "Helpers for writing expectation tests";
    propagatedBuildInputs = [
      base
      base_quickcheck
      portable
      ppx_jane
      sexp_pretty
      stdio
    ];
    buildInputs = [
      re
    ];
  };

  expect_test_helpers_core = janePackage {
    pname = "expect_test_helpers_core";
    rev = "6f3d46743213c41c12c2af1141c0c62b3805c80f";
    hash = "sha256-iCVpxPuzZA1swIsXoZ5JWgLLzPgyPo1hiE9od248m/M=";
    meta.description = "Helpers for writing expectation tests";
    propagatedBuildInputs = [
      core
      expect_test_helpers_base
      ppx_jane
      re
      sexp_pretty
    ];
  };

  expectable = janePackage {
    pname = "expectable";
    rev = "fd9413638f591f50d9fc561904c1fcf2a13e7b12";
    hash = "sha256-gxVOy2DTjPiUUqHPHY+/jNqEjbgATPva+mBzLk4MUk0=";
    meta.description = "Library that makes it easier to print ASCII tables in tests";
    propagatedBuildInputs = [
      base
      core
      ppx_jane
      textutils
    ];
  };

  expectree = janePackage {
    pname = "expectree";
    rev = "feb430bade693d2c133cf7eb6975ffee818ecd5d";
    hash = "sha256-u3RRvfAp1zWp02WyxT8TOcFqIT3BNbFLWaR0S7dWhok=";
    meta.description = "Utility library for pretty-printing sexps as trees";
    propagatedBuildInputs = [
      base
      core
      ppx_jane
    ];
  };

  fieldslib = janePackage {
    pname = "fieldslib";
    rev = "1ade082757c2499ed7bb391233f57c7e326ddbed";
    hash = "sha256-9aEzlGZANz687scK/fv3CoQbO3V1y38xr/NY2hfjJ9U=";
    meta.description = "Syntax extension to define first class values representing record fields, to get and set record fields, iterate and fold over all fields of a record and create new record values";
    propagatedBuildInputs = [
      base
    ];
  };

  flexible_sexp = janePackage {
    pname = "flexible_sexp";
    rev = "7e20c93317424ea590f4cbf6b37376129cd3816c";
    hash = "sha256-HhPMC4e801NTtNwGpZNKdPXNHqpOQF289K59Ctw5Cl4=";
    meta.description = "Library for creating stable sexp serialization with forward compatibility";
    propagatedBuildInputs = [
      basement
      core
      ppx_jane
      string_dict
    ];
  };

  float_array = janePackage {
    pname = "float_array";
    rev = "604982747b925b637da2341de0efe1b5706af823";
    hash = "sha256-csntfmg6Pw+K+zQeO2SnZJoRJgtBJDLzOfHNm/vueOE=";
    meta.description = "Mutable vector of floats with efficient operations";
    propagatedBuildInputs = [
      bin_prot
      core
      ppx_jane
    ];
  };

  incr_map = janePackage {
    pname = "incr_map";
    rev = "1d12f6febcafec811b82e0075b5c3ea9feab8236";
    hash = "sha256-4AGzNi9ys/D4URZc3tO1ifR0UOkXRcDhEk2rhisbcx4=";
    meta.description = "Helpers for incremental operations on map like data structures";
    propagatedBuildInputs = [
      abstract_algebra
      bignum
      core
      incremental
      legacy_diffable
      ppx_diff
      ppx_jane
      ppx_pattern_bind
      ppx_stable_witness
      streamable
    ];
  };

  incr_select = janePackage {
    pname = "incr_select";
    rev = "808b4feaa71dff86eb9130046fe8aa645702e9e4";
    hash = "sha256-0U5JKcOeuioikjSOuVRZ64JwoA0TPLTURBWVDWpjHec=";
    meta.description = "Handling of large set of incremental outputs from a single input";
    propagatedBuildInputs = [
      core
      incremental
      ppx_jane
    ];
  };

  incremental = janePackage {
    pname = "incremental";
    rev = "5dde57ea02101966267f1a8b099a434dd57417c2";
    hash = "sha256-jQvhSSevAYZYtcVKjuPNBf4zDkkyJSgVXrvcUO1Ncq8=";
    meta.description = "Library for incremental computations";
    propagatedBuildInputs = [
      core
      core_kernel
      janestreet_lru_cache
      ppx_jane
      ppx_optcomp
      textutils_kernel
    ];
  };

  int_repr = janePackage {
    pname = "int_repr";
    rev = "c9d82d72c487810ece8404febd4cd409ce1009c7";
    hash = "sha256-Oaxkluwc1+1qJG0f47vEp/FWhru4vv7q6MLU3LldkIw=";
    meta.description = "Integers of various widths";
    propagatedBuildInputs = [
      base
      ppx_jane
    ];
  };

  jane-street-headers = janePackage {
    pname = "jane-street-headers";
    rev = "f9495480c1c13cacd6adf610395607c31ef2b32c";
    hash = "sha256-9LQB9XR26fxM+9QB8myfiWvHR4XPzU/GBwo4vtw5hXU=";
    meta.description = "Jane Street C header files";
  };

  jane_rope = janePackage {
    pname = "jane_rope";
    rev = "3eaef8e926818246ad37ff86ff73697147929259";
    hash = "sha256-pd9yx3vy7JUbyQ72bwp9soIbgaxcXYxLTvuIenw0Roo=";
    meta.description = "String representation with cheap concatenation";
    propagatedBuildInputs = [
      base
      ppx_jane
    ];
  };

  jane_term_types = janePackage {
    pname = "jane_term_types";
    rev = "f5e05a27ede9f71baccb193fe1b0d6665ac89fca";
    hash = "sha256-tsBV7WQm2VKIJYsyEmPzLOBDG18dHRAr101wvn0gBvE=";
    meta.description = "Types for interacting with the terminal";
    propagatedBuildInputs = [
      core
      ppx_jane
    ];
  };

  janestreet_lru_cache = janePackage {
    pname = "janestreet_lru_cache";
    rev = "499213444a39f69e26d7a45da9f7d3d8d5f4ba5e";
    hash = "sha256-SMEsXe9pVa5uWWBfpGXNlomsidg8JEDPHFn0L9e/D9w=";
    meta.description = "LRU Cache implementation";
    propagatedBuildInputs = [
      core
      ppx_jane
    ];
  };

  jst-config = janePackage {
    pname = "jst-config";
    rev = "b506c5bc2b2978581709fbb8f86182e690c0bbcc";
    hash = "sha256-T8za07HcFSF32p1sirFosqnxnGv5Mj9QNg7Fje02W3I=";
    meta.description = "Compile-time configuration for Jane Street libraries";
    propagatedBuildInputs = [
      base
      ppx_assert
    ];
    buildInputs = [
      dune-configurator
    ];
  };

  legacy_diffable = janePackage {
    pname = "legacy_diffable";
    rev = "e13041edb1596dd70178cf711e6ed2997e209ede";
    hash = "sha256-sm67rcq3/RaSsp4kPzt1gOEppxXU1nEZV9/YiVXJosE=";
    meta.description = "Interface for diffs";
    propagatedBuildInputs = [
      core
      ppx_jane
      stored_reversed
      streamable
    ];
  };

  nonempty_list_type = janePackage {
    pname = "nonempty_list_type";
    rev = "dfc5f5f76cf9a629518e1d3945392c344a869874";
    hash = "sha256-b3lr8l6RdES/Zgi+7Cnr2glddMr9e7xt/divJmYoVMA=";
    meta.description = "Underlying type of `Base.Nonempty_list.t`";
  };

  notty_async = janePackage {
    pname = "notty_async";
    rev = "de5fba79a731a270561b731a98506951f25319fa";
    hash = "sha256-c6sf9Nf0QNLD2sbTv/vKVUzKliakSGbe/oHGRkSB4xY=";
    meta.description = "Async driver for Notty";
    propagatedBuildInputs = [
      async
      core_unix
      notty-community
      ppx_jane
    ];
  };

  ocaml-embed-file = janePackage {
    pname = "ocaml-embed-file";
    rev = "02a9f7589c2bc5794eb7923b56759472dffb4e8c";
    hash = "sha256-9fkZTqWcvdcjA2SDmN2J+4Y556Rgz8oddVKWS8OAeno=";
    meta.description = "Files contents as module constants";
    propagatedBuildInputs = [
      async
      async_kernel
      async_unix
      core
      core_unix
      ppx_jane
    ];
  };

  ocaml_intrinsics = janePackage {
    pname = "ocaml_intrinsics";
    rev = "d6194d5795de5729bbbed8447001d49e355728af";
    hash = "sha256-a8CCGZsWJOnX6Cz4O5sTA52dGEzFL7Y2ov5kDTjLVzU=";
    meta.description = "Library of intrinsics for OCaml";
    propagatedBuildInputs = [
      ocaml_intrinsics_kernel
      ppx_builtin
    ];
    buildInputs = [
      ocaml-compiler-libs
    ];
  };

  ocaml_intrinsics_kernel = janePackage {
    pname = "ocaml_intrinsics_kernel";
    rev = "1cbb60a80984abcdc1618102eb31957b7f9d78d2";
    hash = "sha256-WKW6gCc9yeSt/i+RE49oKVDGuQBhCkF7NFOpEh5vAH0=";
    meta.description = "Kernel library of intrinsics for OCaml";
  };

  parsexp = janePackage {
    pname = "parsexp";
    rev = "35fb9469eba0361f4a5ebc5ecc1db22fde1c6742";
    hash = "sha256-cdwrub758nRmqaRTJcOe4rA7W14EPCqevdYiB89Ae0Q=";
    meta.description = "S-expression parsing library";
    propagatedBuildInputs = [
      basement
      capsule0
      ppx_js_style
      ppx_sexp_conv
      sexplib0
      unique
    ];
  };

  patdiff = janePackage {
    pname = "patdiff";
    rev = "41af3f61279a29b21294bac74112a8ef10518614";
    hash = "sha256-IyJ3v6ABRLPq/btTPES+mc+sKBrtr9rmNYCKgXo3LJI=";
    meta.description = "File Diff using the Patience Diff algorithm";
    # The cram tests shell out to a `visible_colors` helper that is not built by
    # `dune build -p patdiff`, so every colour test reports `command not found`.
    doCheck = false;
    propagatedBuildInputs = [
      angstrom
      base
      core
      core_extended
      core_kernel
      core_unix
      expect_test_helpers_base
      patience_diff
      ppx_jane
      re
      uucp
    ];
  };

  patience_diff = janePackage {
    pname = "patience_diff";
    rev = "9db2f0991d9656c8d4121e520864adcebaf205e0";
    hash = "sha256-K2oz9eO7RRpwBgOEG7SOEOH7zR9erLScjd+djNaxA9g=";
    meta.description = "Diff library using Bram Cohen's patience diff algorithm";
    propagatedBuildInputs = [
      base
      core
      ppx_jane
    ];
  };

  pending_or_error = janePackage {
    pname = "pending_or_error";
    rev = "5e6d31576ccb36aeee0ae2097666d3b8bff8cb0b";
    hash = "sha256-UXF1ScbSUizlSBSulwHQrIcx0nqauRnGXmFG9wUKVsI=";
    meta.description = "Type useful for representing asynchronous results";
    propagatedBuildInputs = [
      core
      ppx_diff
      ppx_jane
    ];
  };

  pipe_with_writer_error = janePackage {
    pname = "pipe_with_writer_error";
    rev = "5bde7e8d9790adb32e320f0e8e6387000f0f7ca0";
    hash = "sha256-7ahyTAzZ8CYW3+ER882uJYFwBTdUbd9qK3yeTMxrEZc=";
    meta.description = "Pipe that forces readers to consider errors from writers while reading";
    propagatedBuildInputs = [
      async_kernel
      core
      ppx_jane
    ];
  };

  portable = janePackage {
    pname = "portable";
    rev = "6c84a26c139049b2fb488d3190e38e18df722355";
    hash = "sha256-hgZFtMvfT4vSd0OT0elIEWo3UcwFNuqq1PZd5os/sZI=";
    meta.description = "Library for parallel programming in OCaml and OxCaml";
    propagatedBuildInputs = [
      base
      base_quickcheck
      basement
      capsule
      ppx_compare
      ppx_sexp_conv
      ppx_shorthand
      ppx_template
    ];
  };

  portable_lockfree_htbl = janePackage {
    pname = "portable_lockfree_htbl";
    rev = "389ca5ba4326d19f6c6de801ef14a4e84a3e6457";
    hash = "sha256-sVQ3oC7hmiTLFrYsG400lX2woT0mt7x+vMzEM5qMj/Q=";
    meta.description = "Portable lock-free hash table for OxCaml";
    propagatedBuildInputs = [
      base
      basement
      portable
      ppx_jane
    ];
  };

  ppx_array_base = janePackage {
    pname = "ppx_array_base";
    rev = "fd4fcd232d1ba1ab3aea74c3ca84027cd9844c84";
    hash = "sha256-7KsPY3fP346ymmFH/FpPz9pqL1hRckoybehSbDyNIQk=";
    meta.description = "Defines array functions used in [Base.Array]";
    propagatedBuildInputs = [
      ppx_helpers
      ppxlib_jane
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_assert = janePackage {
    pname = "ppx_assert";
    rev = "a79937e720ee65ab2c4ee61d6728b14588fb211e";
    hash = "sha256-8oOHhshR3hvLMZoVCvFO3dlN+FW7jlGI6xKbotNWmyo=";
    meta.description = "Assert-like extension nodes that raise useful errors on failure";
    doCheck = false;
    propagatedBuildInputs = [
      base
      ppx_compare
      ppx_here
      ppx_sexp_conv
      ppx_template
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_base = janePackage {
    pname = "ppx_base";
    rev = "8c936e32dc2d6d4d052d542e24772a698978aa56";
    hash = "sha256-Ch6yC70nTPXJGbc8IE6i1esNRkhmWMmnGCREycT1PXI=";
    meta.description = "Base set of ppx rewriters";
    propagatedBuildInputs = [
      ppx_compare
      ppx_enumerate
      ppx_globalize
      ppx_hash
      ppx_sexp_conv
      ppx_shorthand
      ppx_template
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_bench = janePackage {
    pname = "ppx_bench";
    rev = "dfe891c0990c6d926d4ce39c981e971cf8b99a9a";
    hash = "sha256-O/fVZ1KcNvRVYV2Xu695mrV+JGkZx7z6sQMUSXavg1U=";
    meta.description = "Syntax extension for writing in-line benchmarks in ocaml code";
    propagatedBuildInputs = [
      ppx_inline_test
      ppxlib_jane
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_bin_prot = janePackage {
    pname = "ppx_bin_prot";
    rev = "9c4b570527e6247368ecca768ce8bf6a9f8072a2";
    hash = "sha256-Ma9eiD307m8mDZIIfAqhzc9RKT/UXw3VIdJB3GlWtko=";
    meta.description = "Generation of bin_prot readers and writers from types";
    doCheck = false;
    propagatedBuildInputs = [
      base
      bin_prot
      ppx_helpers
      ppx_here
      ppxlib_jane
    ];
    buildInputs = [
      ocaml-compiler-libs
      ppxlib
    ];
  };

  ppx_box = janePackage {
    pname = "ppx_box";
    rev = "b4feba9ca5676a2fd2469e9da9223845686dd0d0";
    hash = "sha256-iStJvVi0FUNvC0r0eZFJE8tAwZc+BNo3dpFPURFvQeI=";
    meta.description = "Boxes and unboxes product types";
    propagatedBuildInputs = [
      ppx_helpers
      ppx_jane
      ppx_shorthand
      ppx_template
      ppxlib_jane
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_builtin = janePackage {
    pname = "ppx_builtin";
    rev = "e3a1c6b227206e731daa2a56ae4701593e357dad";
    hash = "sha256-owVc8SVkcR2PI0swzcF7ig5DFhYYHOYXlwJeUpP8jmU=";
    meta.description = "Elides unsupported [@@builtin] attributes";
    propagatedBuildInputs = [
      ppxlib_jane
    ];
    buildInputs = [
      ocaml-compiler-libs
      ppxlib
    ];
  };

  ppx_compare = janePackage {
    pname = "ppx_compare";
    rev = "e6dd5c5dd2b4d4bcadd3d1958f6712fac61df6ee";
    hash = "sha256-my+cR3noLmuRBQIkPjvpJYirEEg06SzDG1JlGoG8ooA=";
    meta.description = "Generation of comparison functions from types";
    propagatedBuildInputs = [
      basement
      ppx_helpers
      ppx_shorthand
      ppx_template
      ppxlib_jane
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_custom_printf = janePackage {
    pname = "ppx_custom_printf";
    rev = "b307149d22b48b96958e05946e26fa6b0b2748bc";
    hash = "sha256-Ec2JMKLAI7CSxoL2MaQla3NlOdhd7iY9xP90gEfR54U=";
    meta.description = "Printf-style format-strings for user-defined string conversion";
    propagatedBuildInputs = [
      base
      ppx_sexp_conv
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_debug_assert = janePackage {
    pname = "ppx_debug_assert";
    rev = "bf1c89d60532e493ed3288ef672d1fb2047138bb";
    hash = "sha256-jHsSjOg2KgxdMWoHDRy9f+6IaYMWInilOHT4Sg3sEyw=";
    meta.description = "Ppx for debug assertions";
    buildInputs = [
      ppxlib
    ];
  };

  ppx_delta_types = janePackage {
    pname = "ppx_delta_types";
    rev = "545e2372e2811ce05b6ba9cf91f699154701790b";
    hash = "sha256-dnwPYBxWXJnpecI9a7+uSRZyn7obvlNYDyitLKIrNAE=";
    meta.description = "Ppx for defining types by their differences from existing types";
    propagatedBuildInputs = [
      base
      core
      ppx_jane
      ppx_stable
      ppxlib
    ];
  };

  ppx_diff = janePackage {
    pname = "ppx_diff";
    rev = "984fcbc0f32429e263f17e8327e3ca875a253183";
    hash = "sha256-FQ1k7T/6l1paWwZRmzuBixmFNVXFs72MQ12iO8NX63I=";
    meta.description = "Generation of diffs and update functions for ocaml types";
    propagatedBuildInputs = [
      base
      ppx_compare
      ppx_enumerate
      ppx_jane
      ppx_stable_witness
      ppx_template
      ppxlib_jane
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_disable_unused_warnings = janePackage {
    pname = "ppx_disable_unused_warnings";
    rev = "b1762a7a6b91bf960597757f6d053f85a4ff555b";
    hash = "sha256-N4qY11CxcawguWd+hLX2KfjZIKfzATULa7VHn4xku18=";
    meta.description = "Expands [@disable_unused_warnings] into a list of warning suppressions";
    buildInputs = [
      ppxlib
    ];
  };

  ppx_embed_file = janePackage {
    pname = "ppx_embed_file";
    rev = "9696cb8900a53d3ff877edeb3859c21aa677b255";
    hash = "sha256-uOYmBawLrADivpUk2r1Ah7u50JXag4dCuIxDUM27b/g=";
    meta.description = "PPX that allows embedding files directly into executables/libraries as strings or bytes";
    propagatedBuildInputs = [
      core
      ppx_jane
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_enumerate = janePackage {
    pname = "ppx_enumerate";
    rev = "c5f0588ad914218f0d356f18364d9beac4a41423";
    hash = "sha256-e9wEWHUIpCN801Yh04lEDiDwnT1Mvz+Pwq9ihkK519Y=";
    meta.description = "Generate a list containing all values of a finite type";
    propagatedBuildInputs = [
      basement
      ppxlib_jane
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_expect = janePackage {
    pname = "ppx_expect";
    rev = "03714d77a282ff466abf5377ca7f29c754ae3b67";
    hash = "sha256-jHqisSBCJOz/gNhssQOS1CWuW9IJzcRX5LUaMbsqzPw=";
    meta.description = "Cram like framework for OCaml";
    doCheck = false;
    propagatedBuildInputs = [
      base
      capsule
      portable
      ppx_fuelproof
      ppx_here
      ppx_inline_test
      stdio
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_fields_conv = janePackage {
    pname = "ppx_fields_conv";
    rev = "cc971541589c86c1ecb39a7b2bb3bd4104f11abc";
    hash = "sha256-eMArufqiCMOp9Gq4C0PqQZF519KuKdwiMAHqree/rUc=";
    meta.description = "Generation of accessor and iteration functions for ocaml records";
    propagatedBuildInputs = [
      base
      fieldslib
      ppx_helpers
      ppxlib_jane
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_fixed_literal = janePackage {
    pname = "ppx_fixed_literal";
    rev = "cc354ffd6f41bb0c96079164d4498c75b2fce0e9";
    hash = "sha256-Vp39LZwC2FKNKH2JZ/tmVWn5pcAD2rMpxUlwP/EDxrg=";
    meta.description = "Simpler notation for fixed point literals";
    doCheck = false;
    propagatedBuildInputs = [
      base
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_for_loop = janePackage {
    pname = "ppx_for_loop";
    rev = "d5fb4b9405e628b7779afa37b20347be9a687af6";
    hash = "sha256-A3XKfVim9T2/3laLnkDpfAe5nL8FBjNudAeEqShiciQ=";
    meta.description = "For-loop syntax that supports unboxed numbers";
    propagatedBuildInputs = [
      base
      ppxlib
      ppxlib_jane
      unboxed
    ];
  };

  ppx_fuelproof = janePackage {
    pname = "ppx_fuelproof";
    rev = "ea678542967aba5687ede64f5daf72ccedc938ff";
    hash = "sha256-S1Q6S21C9zvFSYQCJ2vQ2ZThzivXjdgFHb9NNX+4pO0=";
    meta.description = "Get better error messages and improve mode crossing for types";
    propagatedBuildInputs = [
      base
      ppx_compare
      ppx_let
      ppx_sexp_conv
      ppxlib_jane
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_globalize = janePackage {
    pname = "ppx_globalize";
    rev = "0373ce7583b456853d1a2499defa73f282b80322";
    hash = "sha256-a7v+G9XKF0XqVpZEb60YW2rcnZEhlapBYY+KO7pWY/I=";
    meta.description = "PPX rewriter that generates functions to copy local values to the global heap";
    propagatedBuildInputs = [
      ppx_helpers
      ppxlib_jane
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_hash = janePackage {
    pname = "ppx_hash";
    rev = "ef4fb76ccf0548c4fc4cf8d7f16e8bdbfc903b2e";
    hash = "sha256-tzhoe9YQJnAPt0LV+eo1TPbuJc/8TYni/NnmADVGHV0=";
    meta.description = "PPX rewriter that generates hash functions from type expressions and definitions";
    propagatedBuildInputs = [
      base_internalhash_types
      ppx_compare
      ppx_helpers
      ppx_sexp_conv
      ppxlib_jane
    ];
    buildInputs = [
      ocaml-compiler-libs
      ppxlib
    ];
  };

  ppx_helpers = janePackage {
    pname = "ppx_helpers";
    rev = "07fca91f6fcca4c2e4ae14062e7a169c527c1c85";
    hash = "sha256-m91IAIDs6Y4eqrnAGeVnE4JMsbLUMWbzvK3GGSwB8dI=";
    meta.description = "Miscellaneous helpers for writing PPXes";
    propagatedBuildInputs = [
      ppxlib_jane
      sexplib0
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_here = janePackage {
    pname = "ppx_here";
    rev = "8e7466189be8e7ac0fa3dc5928c38c8886e018d1";
    hash = "sha256-/RHsUC9vW7z6j0W+uMB3DNt4TMKVi0xJqKy+Nj0M9Cc=";
    meta.description = "Expands [%here] into its location";
    doCheck = false;
    propagatedBuildInputs = [
      base
      ppxlib_jane
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_ignore_instrumentation = janePackage {
    pname = "ppx_ignore_instrumentation";
    rev = "8c24f62a5c55c93497099032b0c9603013ed0d2c";
    hash = "sha256-j0ldIXiV/rSe0QTdZoIuQtOGxk6yv/+GK3sbP+QLsH4=";
    meta.description = "Ignore Jane Street specific instrumentation extensions";
    buildInputs = [
      ppxlib
    ];
  };

  ppx_inline_test = janePackage {
    pname = "ppx_inline_test";
    rev = "0966fcf411a27c4c85b1d9732bd3d0d88bfac290";
    hash = "sha256-idX2Aut+b2N5ObvAs3xZgHThkt1wPZ3xbNxTZ/a3MKU=";
    meta.description = "Syntax extension for writing in-line tests in ocaml code";
    doCheck = false;
    propagatedBuildInputs = [
      base
      basement
      ppxlib_jane
      sexplib0
      time_now
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_int63_literal = janePackage {
    pname = "ppx_int63_literal";
    rev = "1ad48bab5535cc2b72b08eab0e61312a66c5332e";
    hash = "sha256-pAtqDouWJZ1/7nkl73+MNPqhNshBt2f4hcFvgiNhyLY=";
    meta.description = "Syntax extension for writing int63 literals";
    propagatedBuildInputs = [
      base
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_jane = janePackage {
    pname = "ppx_jane";
    rev = "c92947b1d87da729c7f6016f1fc82be2b3b9df69";
    hash = "sha256-fHMfNNN0lMoe6nM9SgqHbsUllrgy48vhJf3rKG8i9qc=";
    meta.description = "Standard Jane Street ppx rewriters";
    doCheck = false;
    propagatedBuildInputs = [
      base_quickcheck
      ppx_assert
      ppx_base
      ppx_bench
      ppx_bin_prot
      ppx_custom_printf
      ppx_debug_assert
      ppx_disable_unused_warnings
      ppx_expect
      ppx_fields_conv
      ppx_fixed_literal
      ppx_here
      ppx_ignore_instrumentation
      ppx_inline_test
      ppx_int63_literal
      ppx_let
      ppx_log
      ppx_module_timer
      ppx_optional
      ppx_pipebang
      ppx_sexp_message
      ppx_sexp_value
      ppx_shorthand
      ppx_stable
      ppx_stable_witness
      ppx_string
      ppx_string_conv
      ppx_template
      ppx_tydi
      ppx_typed_fields
      ppx_typerep_conv
      ppx_var_name
      ppx_variants_conv
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_js_style = janePackage {
    pname = "ppx_js_style";
    rev = "840934fb816ec2f3c07f797983ac7ce4a79d2e26";
    hash = "sha256-GY8DxDRMG/RttTGkY3Za83aR4s7yjELMMZED2SlgFhQ=";
    meta.description = "Code style checker for Jane Street Packages";
    propagatedBuildInputs = [
      ocaml-compiler-libs
      odoc-parser
      ppx_template
      ppxlib
      ppxlib_jane
    ];
  };

  ppx_let = janePackage {
    pname = "ppx_let";
    rev = "ac9c0730af5106d2e71b3108c8674fce1ea689a9";
    hash = "sha256-J9m6cu3RP5aYpPurqRhWe7BHHFyN4n31xjASGMq9sPU=";
    meta.description = "Monadic let-bindings";
    doCheck = false;
    propagatedBuildInputs = [
      base
      ppx_helpers
      ppx_here
      ppxlib_jane
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_log = janePackage {
    pname = "ppx_log";
    rev = "37daf5f750127fc75f22a117f7e5791f5ee2e0d9";
    hash = "sha256-lgG+mOP+8sB/Lkw0OUzXgcd9ybJI9vTMC8Tx5VjCyII=";
    meta.description = "Ppx_sexp_message-like extension nodes for lazily rendering log messages";
    propagatedBuildInputs = [
      base
      ppx_compare
      ppx_enumerate
      ppx_expect
      ppx_fields_conv
      ppx_here
      ppx_let
      ppx_sexp_conv
      ppx_sexp_message
      ppx_sexp_value
      ppx_string
      ppx_template
      ppx_variants_conv
      sexplib
      stdio
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_module_timer = janePackage {
    pname = "ppx_module_timer";
    rev = "eead4613b9f260df5d685b242f952a61bd80ce81";
    hash = "sha256-oDBf/8G5khfumwp6y3Q0Xi0J9kz0mVIQ1o5OFMa0JMI=";
    meta.description = "Ppx rewriter that records top-level module startup times";
    propagatedBuildInputs = [
      base
      ppx_base
      ppxlib_jane
      stdio
      time_now
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_optcomp = janePackage {
    pname = "ppx_optcomp";
    rev = "b999599bc39f438ccc6c6aca508ed052a0e8dbbd";
    hash = "sha256-vajxBjNaro6Vgw32H5eMJFaI+FOEnXW+xwUHfhRJ6nU=";
    meta.description = "Optional compilation for OCaml";
    propagatedBuildInputs = [
      ppxlib_jane
    ];
    buildInputs = [
      ocaml-compiler-libs
      ppxlib
    ];
  };

  ppx_optional = janePackage {
    pname = "ppx_optional";
    rev = "6aa5cf0eb4e4208db2815893ecf1a5d8c0104ce5";
    hash = "sha256-Xy5KVVNiy5gyE1PLotWDlYU4ewaFjxha2UoKBSASUMk=";
    meta.description = "Pattern matching on flat options";
    propagatedBuildInputs = [
      base
      ppxlib_jane
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_pattern_bind = janePackage {
    pname = "ppx_pattern_bind";
    rev = "c00c2c5484fa3cad70d36cdc6a72044cb5641439";
    hash = "sha256-ZLAkbITBH3y+JH8XP56HEs4AggMNOQgAKR9pcPp0TAs=";
    meta.description = "PPX for writing fast incremental bind nodes in a pattern match";
    propagatedBuildInputs = [
      base
      ppx_let
      ppxlib_jane
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_pipebang = janePackage {
    pname = "ppx_pipebang";
    rev = "cba4997d78f57a80eb4eeb4335f2370bae00c673";
    hash = "sha256-G9vtNQK1H5b/k1TBYvLrYcQ/I0Yn9vsfL4/W6PsxCow=";
    meta.description = "PPX rewriter that inlines reverse application operators `|>` and `|!`";
    propagatedBuildInputs = [
      ppxlib_jane
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_portable = janePackage {
    pname = "ppx_portable";
    rev = "25dc25bf76dddead4a5178d5901a8431b1bc8310";
    hash = "sha256-IpujsjnJRm1FKpFYP40f91MBJtzDkmLUwQSSxBK20zg=";
    meta.description = "Syntactic help for writing portable code, especially Portable_lazy values";
    propagatedBuildInputs = [
      base
      ppx_js_style
      ppxlib_jane
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_quick_test = janePackage {
    pname = "ppx_quick_test";
    rev = "20ac4a4bc6a44edf2a105db2b73946504bb0f723";
    hash = "sha256-F+iLl6EDAs1dDZ9Fkfjj6ef8xj+DW+NcDkwpIwQRLm0=";
    meta.description = "Spiritual equivalent of let%expect_test, but for property based tests";
    propagatedBuildInputs = [
      async
      async_kernel
      base
      base_quickcheck
      core
      expect_test_helpers_async
      expect_test_helpers_base
      ocaml-compiler-libs
      ppx_expect
      ppx_helpers
      ppx_here
      ppx_inline_test
      ppx_jane
      ppx_sexp_conv
      ppx_sexp_message
      ppxlib
      ppxlib_jane
      stdio
    ];
  };

  ppx_sexp_conv = janePackage {
    pname = "ppx_sexp_conv";
    rev = "18236defe35c20191db2dd50aa35a11718155962";
    hash = "sha256-cjpqOiaLkgj7gRuqeelRYL3b3lEukCnAwrwlD7VjOF8=";
    meta.description = "[@@deriving] plugin to generate S-expression conversion functions";
    propagatedBuildInputs = [
      basement
      ppx_helpers
      # ppx_sexp_conv's dune-package requires ppxlib, so consumers (uri-sexp,
      # ...) fail with `Library "ppxlib" not found` unless it is propagated.
      ppxlib
      ppxlib_jane
      sexplib0
    ];
  };

  ppx_sexp_message = janePackage {
    pname = "ppx_sexp_message";
    rev = "6ed4f6a656acb43fc2385df35c251fe03611e695";
    hash = "sha256-u4ieDL5JLJIpXb5izzET5bxmOQGEjzwUuqO7RZMoj9A=";
    meta.description = "PPX rewriter for easy construction of s-expressions";
    doCheck = false;
    propagatedBuildInputs = [
      base
      ppx_here
      ppx_sexp_conv
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_sexp_value = janePackage {
    pname = "ppx_sexp_value";
    rev = "0a57ce10b2a60305f2c282064fffccb822449415";
    hash = "sha256-jh2q1qGCAogXf4NVNefMpW8D7PcEm2Ufu99GqxCPoo4=";
    meta.description = "PPX rewriter that simplifies building s-expressions from ocaml values";
    propagatedBuildInputs = [
      base
      ppx_here
      ppx_sexp_conv
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_shorthand = janePackage {
    pname = "ppx_shorthand";
    rev = "d901635ab94abdd9e97a15d534a9a2158ecf393c";
    hash = "sha256-CD/sCmjivjLz7e6zwHR3JcOWfVhpa7vPkAD/KLo+BKQ=";
    meta.description = "Grab-bag of small but useful AST transformations";
    propagatedBuildInputs = [
      ppxlib_jane
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_stable = janePackage {
    pname = "ppx_stable";
    rev = "e532009d6c1373332c567195dc5ed1e7e958bd41";
    hash = "sha256-FEB8HuMs0PJuvIdc2TAzD1RUp2bpSaZSCS6uJ0/P34k=";
    meta.description = "Stable types conversions generator";
    propagatedBuildInputs = [
      base
      ppx_template
      ppxlib_jane
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_stable_witness = janePackage {
    pname = "ppx_stable_witness";
    rev = "723fcef7e2fa7e5f932b5665c0b2a6bcd2ef0107";
    hash = "sha256-Uc5Brr0VKEsAg0cqVhKTqVnVu3xTapj7nD0fnZSvyrI=";
    meta.description = "Ppx extension for deriving a witness that a type is intended to be stable";
    propagatedBuildInputs = [
      base
      basement
      ppxlib_jane
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_string = janePackage {
    pname = "ppx_string";
    rev = "910b004dc4c49dd149caf446eee41f6c009a6732";
    hash = "sha256-lC7XIJkcWgdX3T9klBcRWgxBXHIx+LDzqmj9Zh+sxvU=";
    meta.description = "Ppx extension for string interpolation";
    propagatedBuildInputs = [
      base
      ppx_base
      ppx_template
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_string_conv = janePackage {
    pname = "ppx_string_conv";
    rev = "8d97de0876fd31c395ed481b27863d78090f8ea5";
    hash = "sha256-81ahmVdV2SCUrFLm/M2NhUG2k5iDowUCOBSVPER4nyI=";
    meta.description = "Ppx to help derive of_string and to_string, primarily for variant types";
    propagatedBuildInputs = [
      base
      capitalization
      ppx_let
      ppx_string
      ppxlib_jane
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_template = janePackage {
    pname = "ppx_template";
    rev = "b078d81defaea8d76c8b0c2e5dfd45271623b4f9";
    hash = "sha256-rUaqFYml4L20SS/OWZi2OdNshO/J9ZNci1ZaH9wQNjA=";
    meta.description = "C++-style templates for kind, mode, modality, and allocator polymorphism";
    propagatedBuildInputs = [
      nonempty_list_type
      ppx_helpers
      ppxlib
      ppxlib_jane
      sexplib0
    ];
  };

  ppx_tydi = janePackage {
    pname = "ppx_tydi";
    rev = "dd2dde4cc3b9955958f3fa29f73047b10273d9e6";
    hash = "sha256-iaYS0yIUEGVWEt0Oh/CUgK+m8OwJjUj2Bmvd7mvbsdo=";
    meta.description = "Let expressions, inferring pattern type from expression";
    propagatedBuildInputs = [
      base
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_typed_fields = janePackage {
    pname = "ppx_typed_fields";
    rev = "5f91fe346d8f88935a255fc4493633163f668058";
    hash = "sha256-s0p7gkVOjSRrBk1Tb+QXbXnelt/eX80FaSEFuLxUwTk=";
    meta.description = "GADT-based field accessors and utilities";
    propagatedBuildInputs = [
      base
      ppx_base
      ppx_compare
      ppx_enumerate
      ppx_globalize
      ppx_hash
      ppx_pipebang
      ppx_sexp_conv
      ppx_sexp_message
      ppx_string
      ppx_template
      ppxlib_jane
      sexplib
      sexplib0
      univ_map
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_typerep_conv = janePackage {
    pname = "ppx_typerep_conv";
    rev = "55ede796b1089c1a760bcb0dc48ac30565893880";
    hash = "sha256-rjiiPmv0hNclu1AbpoXCvLoDCH3l1qoWAf6G9xk5DXI=";
    meta.description = "Generation of runtime types from type declarations";
    propagatedBuildInputs = [
      base
      ppx_helpers
      ppx_let
      ppx_template
      ppxlib_jane
      typerep
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_var_name = janePackage {
    pname = "ppx_var_name";
    rev = "1890b35ffe7e3b979af6691b592c5691a324b190";
    hash = "sha256-L5FS3Wz19ZXgDIZZqTUxiUGFIqwcPwjwGc90ujY+3gs=";
    meta.description = "Allows you to reference the OCaml variable name in RHS expressions";
    propagatedBuildInputs = [
      base
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_variants_conv = janePackage {
    pname = "ppx_variants_conv";
    rev = "8cee9188f163363d9a64c5b6e15bb12c876964bc";
    hash = "sha256-dv3di51Ppu42gm58g3iN7+mIfZtqbFTPOnTunaec7i8=";
    meta.description = "Generation of accessor and iteration functions for ocaml variant types";
    propagatedBuildInputs = [
      base
      ppxlib_jane
      variantslib
    ];
    buildInputs = [
      ppxlib
    ];
  };

  ppx_yojson_conv = janePackage {
    pname = "ppx_yojson_conv";
    rev = "33c96b5fedd43bc411570057844bede561712cb6";
    hash = "sha256-qL58TVZrLGuoS1cYC/vbIDcefEA7b17B6ZCvJ+hDLCc=";
    meta.description = "[@@deriving] plugin to generate Yojson conversion functions";
    propagatedBuildInputs = [
      base
      capitalization
      ppx_jane
      ppx_yojson_conv_lib
      ppxlib
      ppxlib_jane
    ];
  };

  # The standalone nixpkgs ppx_yojson_conv_lib is a v0.17 package; nothing in
  # this scope can use it, because ppx_yojson_conv's expander reads OxCaml's
  # Parsetree (Ptyp_var carries a jkind annotation there).
  ppx_yojson_conv_lib = janePackage {
    pname = "ppx_yojson_conv_lib";
    rev = "3e1f69663978f429ba585a3e2c2efefe54c451fd";
    hash = "sha256-otlRkem0uvAzQN+rYudYMtwJkP4VbcTXG2qF0bJnzHs=";
    meta.description = "Runtime lib for ppx_yojson_conv";
    # Its opam file caps yojson below 3.0.0, and it means it: the scope's
    # default yojson 3.0.0 dropped the `Tuple and `Variant constructors that
    # Yojson.Safe.t still has here.
    propagatedBuildInputs = [ yojson_2 ];
  };

  ppx_with = janePackage {
    pname = "ppx_with";
    rev = "fb8e18626e7751b4863653725938e297f17f05e3";
    hash = "sha256-4G2peuQH6F46vnkSXTEA4XBeOUilh2tnNbsQ5sEBjjo=";
    meta.description = "Ppx writer for consisely building scoped operations";
    propagatedBuildInputs = [
      base
      ppxlib
      ppxlib_jane
    ];
  };

  ppxlib_jane = janePackage {
    pname = "ppxlib_jane";
    rev = "52e90008fbdc22fc0f880aa827faf10257a9b2a6";
    hash = "sha256-BJMPXUk+4hnp5Qn9NFAgZIjWaE4RdNFUsZgFWoCR0Sg=";
    meta.description = "Library for use in ppxes for constructing and matching on ASTs corresponding to the augmented parsetree";
    propagatedBuildInputs = [
      ppxlib_ast
    ];
  };

  protocol_version_header = janePackage {
    pname = "protocol_version_header";
    rev = "c3b80319f2f8be7dc0b0fe07f088568d9f1d25dd";
    hash = "sha256-UY99kpjAcGoVydtmjFnugPlnBOE/n8fC9M7SAs0+5zI=";
    meta.description = "Protocol versioning";
    propagatedBuildInputs = [
      core
      ppx_jane
      ppx_stable_witness
    ];
  };

  record_builder = janePackage {
    pname = "record_builder";
    rev = "67f5b281e8065ecb5e262e65658c088dfeed9799";
    hash = "sha256-IHCfmCL4Dvxk5+cG1oB30mifSzqu/TPd8IEq28/SdCw=";
    meta.description = "Library which provides traversal of records with an applicative";
    propagatedBuildInputs = [
      base
      ppx_jane
    ];
  };

  # The v0.16 re2 the scope would otherwise inherit does not survive the v0.18
  # ppx_inline_test, which rejects the [let%test_module] in its own src/.
  re2 = janePackage {
    pname = "re2";
    rev = "f80e6e3a31483bbed69c94998a503b52d2e0dc7b";
    hash = "sha256-BDdlWeD1C6cirZACRhzzGxsEbJZFg0QazWIiIrEC3FY=";
    meta.description = "OCaml bindings for RE2, Google's regular expression library";
    propagatedBuildInputs = [
      core
      jane_rope
      ppx_jane
      ppx_stable_witness
      regex_parser_intf
    ];
    # There is no g++ in scope. Unlike the v0.16 package this is the only fix
    # needed: src/dune already declares (language cxx) and passes -x c++.
    prePatch = ''
      substituteInPlace src/re2_c/dune --replace-fail 'CXX=g++' 'CXX=c++'
    '';
  };

  regex_parser_intf = janePackage {
    pname = "regex_parser_intf";
    rev = "9f92352212b505b86e885e2946b104e075463934";
    hash = "sha256-T12k4LRsVTbCFGq4a85R71v8BnnZOq1BdvMAyEE6si0=";
    meta.description = "Interface shared by Re_parser and Re2.Parser";
    propagatedBuildInputs = [ base ];
  };

  sexp_pretty = janePackage {
    pname = "sexp_pretty";
    rev = "ec68bcceb0aec6706453b1be53ee92c2f520f069";
    hash = "sha256-tro0hDsHwWgg4nvromGQ2aX1ozdiUzy4Mbv3yfbjFSg=";
    meta.description = "S-expression pretty-printer";
    propagatedBuildInputs = [
      base
      parsexp
      ppx_base
      sexplib
    ];
    buildInputs = [
      re
    ];
  };

  sexp_type = janePackage {
    pname = "sexp_type";
    rev = "98c8ea4b9a7866bbd05069b020a12f273e96c915";
    hash = "sha256-08tjjzO+3UyLnhPIdGoAveWXscjMtG/+43yR9oOE1yg=";
    meta.description = "Sexp type";
    propagatedBuildInputs = [
      basement
    ];
  };

  sexplib = janePackage {
    pname = "sexplib";
    rev = "f7dd083f44502b5ff25eaf15dd546090cd932358";
    hash = "sha256-XmNVFVoFlX1wEnkNG1MrjI4OhZfk++Edi7RXWbtMEH0=";
    meta.description = "Library for serializing OCaml values to and from S-expressions";
    propagatedBuildInputs = [
      basement
      parsexp
      sexplib0
    ];
    buildInputs = [
      num
    ];
  };

  sexplib0 = janePackage {
    pname = "sexplib0";
    rev = "9673cfb45c4cc746385f7af1a33487b3e61b5717";
    hash = "sha256-78n2hMrwO55srWBzHIGf6AGQXAS2nYxIDqgZeEI3CBw=";
    meta.description = "Library containing the definition of S-expressions and some base converters";
    propagatedBuildInputs = [
      basement
      sexp_type
    ];
  };

  spawn = janePackage {
    pname = "spawn";
    rev = "e24c5102490d51c50f5e77798250d95eb680a5d2";
    hash = "sha256-OVsd6I/WqA1WpJJIMru9ZJh2RZqqjIRlDAfH2HOW9sk=";
    meta.description = "Spawning sub-processes";
    # oxopam spawn.v0.15.1+ox patches add the oxcaml `@@ portable` annotations
    # (core_unix expects Spawn.Pgid to be portable).
    patches = patchesFor "spawn/spawn.v0.15.1+ox" [
      "spawn+src+spawn.ml.patch"
      "spawn+src+spawn.mli.patch"
      "spawn+src+spawn_stubs.c.patch"
    ];
    propagatedBuildInputs = [
      ppx_expect
    ];
  };

  splittable_random = janePackage {
    pname = "splittable_random";
    rev = "f934b1bebe707b1487ef452cf69419a754f619eb";
    hash = "sha256-zjvqk/fV+bJxcUWpg2ghjb9AFmnHiQu1Ybs1NwFil6w=";
    meta.description = "PRNG that can be split into independent streams";
    doCheck = false;
    propagatedBuildInputs = [
      base
      capsule0
      ppx_assert
      ppx_bench
      ppx_inline_test
      ppx_sexp_message
    ];
  };

  stdio = janePackage {
    pname = "stdio";
    rev = "9db7bd06e7d153b807727819cd143e741d5689bd";
    hash = "sha256-wm8n9rkwml5E51laBrBXQthmV6CsqWPOW+yjHd+4uME=";
    meta.description = "Standard IO library for OCaml";
    propagatedBuildInputs = [
      base
      sexplib0
    ];
  };

  stored_reversed = janePackage {
    pname = "stored_reversed";
    rev = "95ab43416454017898eb3e09b2722d529578b67a";
    hash = "sha256-mBRuAWX4mxbLjSCybiJ5nMfhTTRDc69raCChpco4SVc=";
    meta.description = "Library for representing a list temporarily stored in reverse order";
    propagatedBuildInputs = [
      core
      ppx_jane
    ];
  };

  streamable = janePackage {
    pname = "streamable";
    rev = "3aead42237cded2579f595fc5435f2d39cd6a51c";
    hash = "sha256-Rr4CAT+zp1riYO9xCCWEXt1IsaA0yNa73Pt5s00CcmI=";
    meta.description = "Collection of types suitable for incremental serialization";
    propagatedBuildInputs = [
      async_kernel
      async_rpc_kernel
      base
      bin_prot
      core
      core_kernel
      ppx_jane
      ppxlib_jane
    ];
    buildInputs = [
      ppxlib
    ];
  };

  string_dict = janePackage {
    pname = "string_dict";
    rev = "8c8680a9938324f58d2475d47755c042e757e349";
    hash = "sha256-psCSEWQnpyKmGTZyWCxefF0J7JqUwQqOmE6aICoqH5M=";
    meta.description = "Efficient static string dictionaries";
    propagatedBuildInputs = [
      base
      basement
      ppx_compare
      ppx_hash
    ];
  };

  textutils = janePackage {
    pname = "textutils";
    rev = "e1f148e07ade794db410967188fb92517c07fca8";
    hash = "sha256-GGZC0uC9tpbTxEVqI4T+UvLgoAdCXTxUdZ/K5p7Q46k=";
    meta.description = "Text output utilities";
    propagatedBuildInputs = [
      core
      core_kernel
      core_unix
      ppx_jane
      # textutils.ascii_table_kernel links uutf, so it has to be propagated or
      # consumers fail with `Library "uutf" not found`.
      uutf
    ];
  };

  textutils_kernel = janePackage {
    pname = "textutils_kernel";
    rev = "e6a9ff5eae45f415a024ab01412a8facc0726ed3";
    hash = "sha256-uJ1zYshdXNMYeblKQNS7cDX+EJYq0c8obBN9YpwHmkE=";
    meta.description = "Text output utilities";
    propagatedBuildInputs = [
      core
      ppx_jane
      uutf
    ];
  };

  time_now = janePackage {
    pname = "time_now";
    rev = "af657383c7e58317b7df437193adb8748bc5c6c3";
    hash = "sha256-kX2Yi+F7y2rKBcgGL2IymOlp94rz/V40Roop0nEpQag=";
    meta.description = "Reports the current time";
    propagatedBuildInputs = [
      base
      jane-street-headers
      jst-config
      ppx_optcomp
    ];
  };

  tmux = janePackage {
    pname = "tmux";
    rev = "f1f23eff14d065fa566bc08d1c632942f3626213";
    hash = "sha256-Q3zXd1+PT35kZ7/lgFDllyUh6RN6tptjphY2U8vw+2c=";
    meta.description = "Bindings for running a tmux session";
    propagatedBuildInputs = [
      async
      core
      core_unix
      jane_term_types
      ppx_jane
    ];
  };

  typerep = janePackage {
    pname = "typerep";
    rev = "d70677cde0a32e3f033c1dadf73a4a3215ab0137";
    hash = "sha256-bT9VoCM3t1fBu5Tl+BANJ+s4h1lmnMZ6HFIVoHwLIjE=";
    meta.description = "Typerep is a library for runtime types";
    propagatedBuildInputs = [
      base
      portable
      ppx_template
    ];
  };

  unboxed = janePackage {
    pname = "unboxed";
    rev = "574a6ef003012990bbf196171ed7fd4da3b85cc1";
    hash = "sha256-k58uaf6jyi/cmOeZf06l/a9nuBNFYlowFfRNmdr++t8=";
    meta.description = "Unboxed types for OxCaml";
    propagatedBuildInputs = [
      base
      bin_prot
      core
      float_array
      ocaml_intrinsics_kernel
      ppx_box
      ppx_jane
      sexplib
      typerep
    ];
  };

  unboxed_datatypes = janePackage {
    pname = "unboxed_datatypes";
    rev = "7f9a7a7d386a57c23596ed2b9f274afabf603322";
    hash = "sha256-oPrjzk2E/gWtI8ZNmoI+Q955A2Yk3rojm5DE3A2wwu8=";
    meta.description = "OxCaml Unboxed Datatypes";
    propagatedBuildInputs = [
      base
      ppx_jane
    ];
  };

  unique = janePackage {
    pname = "unique";
    rev = "41c641a21d1dcc4868d7a474fa91ed1aff9d755e";
    hash = "sha256-XEyWLZPNT0RPGNLPB25p3cb1pMaj20b/54iL7qUzVzo=";
    meta.description = "Unique value containers for OxCaml";
    propagatedBuildInputs = [
      basement
      ppx_template
    ];
  };

  univ_map = janePackage {
    pname = "univ_map";
    rev = "4746a8c4c0b16cebc6dd3c27a73066b0d1eb34c9";
    hash = "sha256-zQVdR58S1V+sBxjSCNiZotECt+sixpDIVFXK2xeu2Zs=";
    meta.description = "Universal/heterogeneous maps, useful for storing values of arbitrary type in a single map";
    doCheck = false;
    propagatedBuildInputs = [
      base
      ppx_base
      ppx_here
      ppx_inline_test
      ppx_sexp_message
      ppx_sexp_value
    ];
  };

  uopt = janePackage {
    pname = "uopt";
    rev = "d706c1b5926656eb58c9ff6ee2af84d9bf960551";
    hash = "sha256-d6soLEK+VcMeRQENbxpDLKqdfmoJFXyKvrgX0ZqbWL4=";
    meta.description = "[option]-like type that incurs no allocation";
    propagatedBuildInputs = [
      base
      ppx_jane
    ];
  };

  variantslib = janePackage {
    pname = "variantslib";
    rev = "863fe62e00e59c4ef29ce69fca7fe0f15e7378b8";
    hash = "sha256-rA2/ABnQBh4oJrC4ej+Ke00SOdha5U1qKbPBrQlIXWM=";
    meta.description = "Part of Jane Street's Core library";
    propagatedBuildInputs = [
      base
    ];
  };

  vec = janePackage {
    pname = "vec";
    rev = "f8a9c56c7591138851a26b24d748f19d25540d3b";
    hash = "sha256-40mkxT6JGewZfHU5+XntEK4Poh3OI/c6Idd5FSINUvY=";
    meta.description = "Growable array";
    propagatedBuildInputs = [
      core
      ppx_for_loop
      ppx_jane
      ppx_stable_witness
      unboxed
    ];
  };

  virtual_dom = janePackage {
    pname = "virtual_dom";
    rev = "d4be5216a74027f8eb5f73f7c2f600f85b5dcbe2";
    hash = "sha256-6k1I04ejdGhu28JGeBwZlLf2ecBkuxQcw0NF7rhvtSE=";
    meta.description = "OCaml bindings for the virtual-dom library";
    propagatedBuildInputs = [
      async
      async_kernel
      base
      core
      core_kernel
      ppx_jane
      sexplib
      stdio
    ];
    buildInputs = [
      base64
      gen_js_api
      js_of_ocaml
      js_of_ocaml-ppx
      lambdasoup
      tyxml
      uri
    ];
  };

  zarith_stubs_js = janePackage {
    pname = "zarith_stubs_js";
    rev = "e8875f5c0517ccdc0d67537e8d9521756f759b7c";
    doCheck = false;
    hash = "sha256-V1qcDj9Y5M90XMxnWYGxpVu12uYJK3o/sVYCDxNaLe8=";
    meta.description = "Javascripts stubs for the Zarith library";
  };
}
