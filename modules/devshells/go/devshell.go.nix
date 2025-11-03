{
  # Define per-system modules.
  # It is a function that takes `pkgs` and many other parameters.
  # The `pkgs` parameter is the package set for the given system architecture.
  perSystem =
    { pkgs, ... }:
    {
      # Development shell definition.
      devShells.go = pkgs.mkShell {
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
}
