# in /etc/nixos/overlays/
final: prev:
with prev.lib;
let
  # Load system config and get nixpkgs overlay option
  overlays = (import <nixpkgs/nixos> {}).config.nixpkgs.overlays;
in
  # Apply all overlays to the current "main" overlays
  foldl' (flip extends) (_: prev) overlays final