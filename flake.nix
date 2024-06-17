# file: flake.nix
{
  description = "BigQuery newline-delimited JSON client";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.poetry2nix.url = "github:nix-community/poetry2nix";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    inputs@{
      self,
      nixpkgs,
      poetry2nix,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          bqpy = import ./default.nix {
            inherit pkgs;
            inherit inputs;
            inherit system;
          };
          default = self.packages.${system}.bqpy;
        };

        # Shell for app dependencies.
        #
        #     nix develop
        #
        # Use this shell for developing your app.
        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.bqpy ];
          # packages = [ self.packages.${system}.bqpy ];
        };

        # Shell for poetry.
        #
        #     nix develop .#poetry
        #
        # Use this shell for changes to pyproject.toml and poetry.lock.
        devShells.poetry = pkgs.mkShell { packages = [ pkgs.poetry ]; };

        # bq.py app
        #
        #    nix run .
        apps.${system}.default = {
          type = "app";
          # replace <script> with the name in the [tool.poetry.scripts] section of your pyproject.toml
          program = "${self.packages.bqpy}/bin/bq.py";
        };
      }
    );
}
