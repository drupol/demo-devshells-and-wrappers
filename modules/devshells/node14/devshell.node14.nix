{ inputs, ... }:
{
  imports = [ inputs.make-shell.flakeModules.default ];

  # Define per-system modules.
  perSystem =
    { pkgs, config, ... }:
    {
      # Development shell definition.
      make-shells.node14 = {
        packages = [
          # This is how to reference a local package.
          config.packages.nodejs14-bin
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
