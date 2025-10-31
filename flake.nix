{
  # Define the inputs for the flake.
  inputs = {
    # Provides the large `nixpkgs` package set.
    nixpkgs.url = "github:NixOS/nixpkgs";
    # Optional: For compatibility with Nix without flake support.
    flake-compat = {
      url = "github:NixOS/flake-compat";
      flake = false;
    };
  };

  # The outputs function defines what this flake provides.
  # Its sole parameter is `inputs`, which contains the resolved inputs.
  outputs =
    inputs:
    let
      # Alias for the Nixpkgs library.
      lib = inputs.nixpkgs.lib;

      # Helper to generate attributes for multiple system architectures.
      # Documentation: https://noogle.dev/f/lib/genAttrs
      forAllSystems =
        fn: lib.genAttrs lib.systems.flakeExposed (system: fn inputs.nixpkgs.legacyPackages.${system});
    in
    {
      # Define development shells for each architecture.
      devShells = forAllSystems (pkgs: {
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
      });
    };
}
