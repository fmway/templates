{
  description = "Nix Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    fmway-lib.url = "github:fmway/lib";
    fmway-lib.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = { fmway-lib, ... } @ inputs: let
    inherit (fmway-lib) lib;
  in lib.mkFlake {
      inherit inputs;
      specialArgs.lib = lib.optionals (lib.pathIsRegularFile ./lib/default.nix) [
        (self: super: lib.fmway.doImport ./lib { lib = self; })
      ];
    } {
      imports = lib.optionals (lib.pathIsRegularFile ./top-level/default.nix) [
        ./top-level
      ] ++ lib.optionals (lib.pathIsDirectory ./modules) [
        # auto create modules
        ({ self, config, lib, ... } @v: {
          flake = lib.fmway.genModules ./modules v;
        })
      ] ++ [
        # expose lib to flake outputs
        ({ lib, ... }: { flake = { inherit lib; }; })
      ];
    };
}
