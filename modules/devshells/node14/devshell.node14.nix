{ inputs, ... }:
{
  # Import the default make-shell module, required for defining development shells.
  # This module provides the `perSystem.make-shells` attribute.
  imports = [ inputs.make-shell.flakeModules.default ];

  # Define per-system modules.
  # It is a function that takes `pkgs` and many other parameters.
  # The `pkgs` parameter is the package set for the given system architecture.
  perSystem =
    # Notice the `config` argument, which allows referencing attributes defined
    # elsewhere in the configuration of this flake.
    { pkgs, config, ... }:
    {
      # Development shell definition.
      make-shells.node14 = {
        packages = [
          # This is how to reference a package created within this flake.
          config.packages.nodejs14-bin
          pkgs.yarn
        ];

        # Optional: Run commands when the shell starts.
        shellHook = ''
          echo ""
          echo ">> NodeJS 14 development environment is ready!"
          echo ""
        '';
      };
    };
}
