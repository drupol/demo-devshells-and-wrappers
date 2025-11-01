{ inputs, ... }:
{
  imports = [ inputs.pkgs-by-name-for-flake-parts.flakeModule ];

  perSystem = {
    # This is a specific option defined by the pkgs-by-name-for-flake-parts module only.
    # It tells the module where to find the package directory in your project.
    pkgsDirectory = ../pkgs;
  };
}
