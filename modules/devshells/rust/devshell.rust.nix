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
      make-shells.rust = {
        # List the packages to be available in the shell.
        packages = with pkgs; [
          cargo
          cargo-nextest
          cargo-watch
          clippy
          gcc
          lldb
          llvmPackages.bintools
          rust-analyzer
          rustc
          rustfmt
          rustup
        ];

        # Optional: Set environment variables.
        env = {
          RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
        };

        # Optional: Run commands when the shell starts.
        shellHook = ''
          export CARGO_HOME="$PWD/.cargo"
          export PATH="$CARGO_HOME/bin:$PATH"

          echo ""
          echo ">> Rust development environment is ready!"
          echo ""
        '';
      };
    };
}
