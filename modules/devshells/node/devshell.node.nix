{ inputs, ... }:
{
  imports = [ inputs.make-shell.flakeModules.default ];

  # Define per-system modules.
  # It is a function that takes `pkgs` and many other parameters.
  # The `pkgs` parameter is the package set for the given system architecture.
  perSystem =
    { pkgs, ... }:
    {
      # Development shell definition.
      make-shells.node = {
        # List the packages to be available in the shell.
        packages = [
          pkgs.nodejs_22
          pkgs.yarn
        ];

        # Optional: Run commands when the shell starts.
        shellHook = ''
          echo ""
          echo ">> NodeJS development environment is ready!"
          echo ""
        '';
      };
    };
}
