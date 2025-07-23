{
  description = "Devenv + flake-parts";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.follows = "devenv/nixpkgs";
    nixpkgs-dev.url = "nixpkgs";
    devenv.url = "github:cachix/devenv";
    fmway-lib.url = "github:fmway/lib";
    fmway-lib.inputs.flake-parts.follows = "flake-parts";
    fmway-lib.inputs.nixpkgs.follows = "nixpkgs";
    fmway-modules.url = "github:fmway/modules";
    fmway-modules.inputs.fmway-lib.follows = "fmway-lib";
    systems.url = "github:nix-systems/default";
    devenv-root.url = "file+file:///dev/null";
    devenv-root.flake = false;
  };

  outputs = inputs@{ fmway-lib, fmway-modules, ... }:
  fmway-lib.lib.mkFlake { inherit inputs; } {
    imports = [ fmway-modules.flakeModules.devenv ];
    perSystem = { config, lib, pkgs, system, ... }: {
      devenv = {
        modules = [
          fmway-modules.devenvModules.some
        ];
        shells.default.imports = [ ./devenv.nix ];
      };
    };
  };
}
