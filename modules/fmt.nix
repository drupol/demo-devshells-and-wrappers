{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem = {
    treefmt = {
      projectRootFile = "flake.nix";
      programs = {
        deadnix.enable = true;
        nixfmt.enable = true;
        prettier.enable = true;
        statix.enable = true;
      };
      settings = {
        on-unmatched = "warn";
      };
    };
  };
}
