{ lib, fetchurl, buildDunePackage
, cmdliner, yojson, ppxlib, findlib
, menhir, menhirLib, sedlex
}:

buildDunePackage rec {
  pname = "js_of_ocaml-compiler";
  version = "5.7.0";
  minimalOCamlVersion = "4.08";

  src = fetchurl {
    url = "https://github.com/ocsigen/js_of_ocaml/releases/download/${version}/js_of_ocaml-${version}.tbz";
    hash = "sha256-zfHeoNk5ekmLYwq+gBSQi23YOxDuDH/1d3pkQ6Ypg74=";
  };

  nativeBuildInputs = [ menhir ];
  buildInputs = [ cmdliner ppxlib ];

  propagatedBuildInputs = [ menhirLib yojson findlib sedlex ];

  meta = {
    description = "Compiler from OCaml bytecode to Javascript";
    homepage = "https://ocsigen.org/js_of_ocaml/";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.vbgl ];
    mainProgram = "js_of_ocaml";
  };
}
