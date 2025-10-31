{
  # Define the inputs for the flake.
  inputs = {
    # Provides the large `nixpkgs` package set.
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  # The outputs function defines what this flake provides.
  # Its sole parameter is `inputs`, which contains the resolved inputs.
  outputs =
    inputs:
    let
      # Helper to generate attributes for multiple system architectures.
      eachSystem = inputs.nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
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
