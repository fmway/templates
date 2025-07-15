{
  description = "Devenv + flake-parts";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.follows = "devenv/nixpkgs";
    nixpkgs-dev.url = "nixpkgs";
    devenv.url = "github:cachix/devenv";
    fmway-nix.url = "github:fmway/fmway.nix";
    fmway-nix.inputs.flake-parts.follows = "flake-parts";
    fmway-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ fmway-nix, ... }: let
    inherit (inputs) self;
  in fmway-nix.fmway.mkFlake { inherit inputs; } {
    imports = [ fmway-nix.flakeModules.devenv ];
    systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
    perSystem = { config, lib, pkgs, system, ... }: {
      devenv = {
        modules = [
          self.devenvModules.default
        ];
        shells.default.imports = [ ./devenv.nix ];
      };
    };

    flake.devenvModules.default = { config, pkgs, name, system, ... }: let
      gitignore = pkgs.writeText "gitignore" ''
        *
        .*
      '';
    in {
      imports = [
        ({ config, lib, ... }: {
          options.nixd.paths = lib.mkOption {
            type = with lib.types; listOf str;
            default = [];
          };

          config.env.NIXD_PATH = let
            result = lib.concatStringsSep ":" config.nixd.paths;
          in lib.mkIf (config.nixd.paths != []) result;
        })
      ];
      config.nixd.paths = [
        "pkgs=${self.outPath}#devShells.${system}.${name}.pkgs"
        "${name}=${self.outPath}#devShells.${system}.${name}.options"
      ];
      config.tasks."devenv:gitignore" = {
        description = "register direnv & devenv to gitignore";
        exec = /* bash */ ''
          ROOT="${config.devenv.root}"
          [ ! -d "$ROOT/.devenv" ] || cp -f "${gitignore}" "$ROOT/.devenv/.gitignore"
          [ ! -d "$ROOT/.direnv" ] || cp -f "${gitignore}" "$ROOT/.direnv/.gitignore"
        '';
        before = [ "devenv:enterShell" ];
      };
    };
  };
}
