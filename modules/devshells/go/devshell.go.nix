{ inputs, ... }:
{
  # Import the default make-shell module, required for defining development shells.
  # This module provides the `perSystem.make-shells` attribute.
  imports = [ inputs.make-shell.flakeModules.default ];

  # Define per-system modules.
  # It is a function that takes `pkgs` and many other parameters.
  # The `pkgs` parameter is the package set for the given system architecture.
  perSystem =
    { pkgs, ... }:
    {
      # Development shell definition.
      make-shells.go = {
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
