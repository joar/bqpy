# file: default.nix
{ inputs ? import ./nix/sources.nix
, pkgs ? import inputs.nixpkgs {}
, ...
}:
let
  # Let all API attributes like "poetry2nix.mkPoetryApplication"
  # use the packages and versions (python3, poetry etc.) from our pinned nixpkgs above
  # under the hood:
  poetry2nix = import inputs.poetry2nix { inherit pkgs; };
  bqpy = poetry2nix.mkPoetryApplication { projectDir = ./.; };
in
bqpy
