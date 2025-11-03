{
  # Define the inputs for the flake.
  inputs = {
    # Provides the large `nixpkgs` package set.
    nixpkgs.url = "github:NixOS/nixpkgs";
    # Optional: For compatibility with Nix without flake support.
    flake-compat = {
      url = "github:NixOS/flake-compat";
      flake = false;
    };
    # flake-parts helps structure the flake outputs.
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  # The outputs function defines what this flake provides.
  # Its sole parameter is `inputs`, which contains the resolved inputs.
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./modules/devshells/php/devshell.php.nix
        ./modules/devshells/go/devshell.go.nix
        ./modules/systems.nix
      ];
    };
}
