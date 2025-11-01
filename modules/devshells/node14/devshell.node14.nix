{ inputs, ... }:
{
  imports = [ inputs.make-shell.flakeModules.default ];

  # Define per-system modules.
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
          echo ">> NodeJS development environment is ready!"
          echo ""
        '';
      };
    };
}
