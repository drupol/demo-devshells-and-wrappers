{
  stdenv,
  fetchurl,
  lib,
  autoPatchelfHook,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nodejs14-bin";
  version = "14.21.3";

  src = fetchurl {
    url = "https://nodejs.org/dist/v${finalAttrs.version}/node-v${finalAttrs.version}-linux-x64.tar.xz";
    hash = "sha256-BcCKEHxQVyqznOnoZjoqLWlrXSYtW9b5jYS5l86TLZo=";
  };

  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out

    cp -ar bin lib $out/

    for file in $(find $out/bin -type l -printf "%f\n"); do
      substituteInPlace $out/bin/$file \
        --replace-fail '#!/usr/bin/env node' "#!${placeholder "out"}/bin/node"
    done

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";

  meta = {
    description = "Node.js binary distribution";
    homepage = "https://nodejs.org/";
    license = lib.licenses.mit;
    mainProgram = "node";
    platforms = [ "x86_64-linux" ];
  };
})
