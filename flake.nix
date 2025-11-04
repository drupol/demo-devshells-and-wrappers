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
    # import-tree helps to import all Nix files from a directory.
    import-tree.url = "github:vic/import-tree";
    # make-shell provides utilities to create development shells more declaratively.
    make-shell.url = "github:nicknovitski/make-shell";
    # Use lassulus/wrappers for making wrapper scripts.
    wrappers.url = "github:lassulus/wrappers";
  };

  # The outputs function defines what this flake provides.
  # Its sole parameter is `inputs`, which contains the resolved inputs.
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
