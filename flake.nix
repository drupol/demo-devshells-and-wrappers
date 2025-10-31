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
      # Helper to generate attributes for multiple system architectures.
      # Documentation: https://noogle.dev/f/lib/genAttrs
      # Note: in this case, it is written in tacit/point-free style for brevity.
      eachSystem = inputs.nixpkgs.lib.genAttrs inputs.nixpkgs.lib.systems.flakeExposed;
    in
    {
      # Define development shells for each architecture.
      devShells = eachSystem (system: {
        default =
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
