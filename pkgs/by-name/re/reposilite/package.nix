{
  lib,
  stdenv,
  fetchurl,
  jre_headless,
  linkFarm,
  makeWrapper,
  nixosTests,
  plugins ? [ ],
}:
let
  pluginsDir = linkFarm "reposilite-plugins" (
    builtins.map (p: {
      name = (builtins.parseDrvName p.name).name + ".jar";
      path = p.outPath or p;
    }) plugins
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "Reposilite";
  version = "3.5.24";

  src = fetchurl {
    url = "https://maven.reposilite.com/releases/com/reposilite/reposilite/${finalAttrs.version}/reposilite-${finalAttrs.version}-all.jar";
    hash = "sha256-HyA59f4Og3bGTe5hEShkAt0jl9rLUBzGAGxUKgJV9Y0=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp $src $out/lib/reposilite
    makeWrapper ${jre_headless}/bin/java $out/bin/reposilite \
      --add-flags "-Xmx40m -jar $out/lib/reposilite ${
        lib.optionalString (plugins != [ ]) "--plugin-directory ${pluginsDir}"
      }"

    runHook postInstall
  '';

  passthru = {
    tests = nixosTests.reposilite;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Lightweight and easy-to-use repository management software dedicated for the Maven based artifacts in the JVM ecosystem";
    homepage = "https://github.com/dzikoysk/reposilite";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      jamalam
      uku3lig
    ];
    inherit (jre_headless.meta) platforms;
    mainProgram = "reposilite";
  };
})
