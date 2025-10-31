{
  # Define the inputs for the flake.
  inputs = {
    # Provides the large `nixpkgs` package set.
    nixpkgs.url = "github:NixOS/nixpkgs";
    # Provides a list of systems supported by Nix (x86_64-linux, aarch64-linux, etc.).
    systems.url = "github:nix-systems/default";
    # flake-parts helps structure the flake outputs.
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  # The outputs function defines what this flake provides.
  # Its sole parameter is `inputs`, which contains the resolved inputs.
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      # The `systems` list determines which platforms to support.
      systems = import inputs.systems;

      # Define per-system modules.
      # It is a function that takes `pkgs` and many other parameters.
      # The `pkgs` parameter is the package set for the given system architecture.
      perSystem =
        { pkgs, ... }:
        {
          # Development shell definition.
          devShells.default = pkgs.mkShell {
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
        };
    };
}
