# This file is a function that takes an argument `pkgs`, which is a set of
# Nix packages. If `pkgs` is not provided, it defaults to importing the
# `<nixpkgs>` repository.
#
# It returns the result of calling `pkgs.mkShell`, which creates a development
# shell environment with the specified packages and a shell hook.
{
  pkgs ? (
    import
      (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/bb3f17b14b21e1f08bd7b5d8e1c37b84066c235f.tar.gz")
      { }
  ),
}:

pkgs.mkShell {
  # List the packages to be available in the shell.
  packages = [
    pkgs.php
    pkgs.php.packages.composer
  ];

  # Optional: Run commands when the shell starts.
  shellHook = ''
    echo ""
    echo ">> PHP development environment is ready!"
    echo ""
  '';
}
