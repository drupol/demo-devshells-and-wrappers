{ inputs, withSystem, ... }:
{
  imports = [ inputs.pkgs-by-name-for-flake-parts.flakeModule ];

  perSystem = {
    # This is a specific option defined by the pkgs-by-name-for-flake-parts module only.
    # It tells the module where to find the package directory in your project.
    pkgsDirectory = ../pkgs;
  };

  flake = {
    # This expose a "default" overlay that can be used in Nix configurations
    # to get access to the packages defined in the ../pkgs/ directory.
    overlays.default =
      _final: prev:
      withSystem prev.stdenv.hostPlatform.system (
        { config, ... }:
        {
          local = config.packages;
        }
      );
  };
}
