{
  # Define the inputs for the flake.
  inputs = {
    # Provides the large `nixpkgs` package set.
    nixpkgs.url = "github:NixOS/nixpkgs";
    # Provides a list of systems supported by Nix (x86_64-linux, aarch64-linux, etc.).
    systems.url = "github:nix-systems/default";
  };

  # The outputs function defines what this flake provides.
  # Its sole parameter is `inputs`, which contains the resolved inputs.
  outputs =
    inputs:
    let
      # Helper to generate attributes for multiple system architectures.
      eachSystem = inputs.nixpkgs.lib.genAttrs (import inputs.systems);
    in
    {
      # Define development shells for each architecture.
      devShells = eachSystem (system: {
        php =
          let
            # Get the package set for the current system architecture.
            pkgs = inputs.nixpkgs.legacyPackages.${system};
          in
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
          };
      });
    };
}
