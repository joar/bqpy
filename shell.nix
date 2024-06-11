{ pkgs ? import <nixpkgs> {}}:

pkgs.mkShell {
  name = "bq-py";
  packages = [
    pkgs.python3
    pkgs.poetry
  ];
}
