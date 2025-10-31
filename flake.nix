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
  outputs = inputs: {
    # Define development shells for `x86_64-linux` architecture/platform only.
    # This means that theses shells will only be available on 64-bit Linux systems.
    devShells.x86_64-linux =
      let
        # Get the package set for the current system architecture and platform.
        pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      in
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
      };
  };
}
