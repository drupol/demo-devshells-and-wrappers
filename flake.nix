{
  # Define the inputs for the flake.
  inputs = {
    # Provides the large `nixpkgs` package set.
    nixpkgs.url = "github:NixOS/nixpkgs";
    # Provides a list of systems supported by Nix (x86_64-linux, aarch64-linux, etc.).
    systems.url = "github:nix-systems/default";
    # flake-parts helps structure the flake outputs.
    flake-parts.url = "github:hercules-ci/flake-parts";
    # import-tree helps to import all Nix files from a directory.
    import-tree.url = "github:vic/import-tree";
  };

  # The outputs function defines what this flake provides.
  # Its sole parameter is `inputs`, which contains the resolved inputs.
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
