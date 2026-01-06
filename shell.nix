# This file is a function that takes an argument `pkgs`, which is a set of
# Nix packages. If `pkgs` is not provided, it defaults to importing an
# instance of the `NixOS/nixpkgs` repository at a specific moment in time.
#
# It returns the result of calling `pkgs.mkShell`, which creates a development
# shell environment with the specified packages and a shell hook.
{
  pkgs ? (
    import (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/bb3f17b14b21e1f08bd7b5d8e1c37b84066c235f.tar.gz";
      sha256 = "sha256:0y7b9kdqrnq11401v4yf8m3ndk8ijcpxbyikmgh7n22nn1v0hyd1";
    }) { }
  ),
}:

{
  php = pkgs.mkShell {
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
  };

  go = pkgs.mkShell {
    # List the packages to be available in the shell.
    packages = [
      pkgs.go
      pkgs.gotools
    ];

    # Optional: Run commands when the shell starts.
    shellHook = ''
      echo ""
      echo ">> Go development environment is ready!"
      echo ""
    '';
  };
}
