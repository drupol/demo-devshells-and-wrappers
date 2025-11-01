{
  # Define the inputs for the flake.
  inputs = {
    # Provides the large `nixpkgs` package set.
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  # The outputs function defines what this flake provides.
  # Its sole parameter is `inputs`, which contains the resolved inputs.
  outputs = inputs: {
    # Define a development shell for x86_64-linux architecture only.
    # This means that this shell will only be available on 64-bit Linux systems.
    devShells.x86_64-linux.default =
      let
        # Get the package set for the current system architecture.
        pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
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
  };
}
