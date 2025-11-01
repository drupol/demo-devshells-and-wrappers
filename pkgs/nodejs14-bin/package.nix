{
  stdenv,
  fetchurl,
  lib,
  autoPatchelfHook,
  versionCheckHook,
  ...
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

  preFixup = ''
    for file in npm npx corepack; do
      substituteInPlace $out/bin/$file \
      --replace-fail '#!/usr/bin/env node' "#!${placeholder "out"}/bin/node"
    done
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -ar bin lib $out/
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/node";
  versionCheckProgramArg = "--version";

  meta = {
    description = "Node.js binary distribution";
    homepage = "https://nodejs.org/";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
})
