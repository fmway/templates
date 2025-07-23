{
  description = "Devenv + flake-parts for rust development";

  inputs = {
    # nixpkgs-dev.url = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.follows = "devenv/nixpkgs";
    devenv.url = "github:cachix/devenv";
    fmway-lib.url = "github:fmway/lib";
    fmway-modules.url = "github:fmway/modules";
    systems.url = "github:nix-systems/default";
    rust-overlay.url = "github:oxalica/rust-overlay";
    devenv-root.url = "file+file:///dev/null";
    devenv-root.flake = false;

    fmway-lib.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    fmway-modules.inputs.fmway-lib.follows = "fmway-lib";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ fmway-lib, fmway-modules, ... }:
  fmway-lib.lib.mkFlake { inherit inputs; } {
    imports = [ fmway-modules.flakeModules.devenv ];
    perSystem = { config, lib, pkgs, system, ... }: {
      devenv = {
        modules = [
          fmway-modules.devenvModules.some
          {
            # overlays = [
            #   (self: super: {
            #     unstable = import inputs.nixpkgs-dev {
            #       config.allowUnfree = true;
            #       inherit system;
            #     };
            #   })
            # ];
          }
        ];
        shells.default.imports = [ ./devenv.nix ];
      };
    };
  };
}
