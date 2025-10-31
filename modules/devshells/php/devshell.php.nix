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
      make-shells.php = {
        # List the packages to be available in the shell.
        packages = [
          (pkgs.symlinkJoin {
            name = "php";
            nativeBuildInputs = [
              pkgs.makeBinaryWrapper
            ];
            paths = [
              pkgs.php
            ];
            postBuild = ''
              wrapProgram $out/bin/php \
                --add-flags "-d memory_limit=512M" \
                --add-flags "-d zend_extension=${pkgs.php.extensions.xdebug}/lib/php/extensions/xdebug.so"
            '';
          })
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
