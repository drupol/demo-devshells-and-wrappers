{ inputs, ... }:
{
  # The `systems` list determines which platforms to support.
  systems = inputs.nixpkgs.lib.systems.flakeExposed;
}
