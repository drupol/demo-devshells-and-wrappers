{
  writeShellApplication,
  curl,
  jq,
  cowsay,
}:

writeShellApplication {
  name = "active-php-version";

  runtimeInputs = [
    curl
    jq
    cowsay
  ];

  text = builtins.readFile ./active-php-version.sh;
}
