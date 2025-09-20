{
  description = "A Typst project";

  outputs = { fmway-nix, ... } @ inputs:
    fmway-nix.lib.mkFlake { inherit inputs; } {
      perSystem = { config, inputs', pkgs, lib, typix, system, ... }: let
        src = typix.cleanTypstSource ./.;
        commonArgs = {
          typstSource = "main.typ";
          fontPaths = [];
          virtualPaths = [];
        };
        commonArgsWithSrc = commonArgs // { inherit src; };
        build-drv = typix.buildTypstProject commonArgsWithSrc;
        build-script = typix.buildTypstProjectLocal commonArgsWithSrc;
        watch-script = typix.watchTypstProject commonArgs;
      in {
        packages.default = build-drv;
        checks = {
          inherit build-drv build-script watch-script;
        };
        devShells.default = typix.devShell {
          inherit (commonArgs) fontPaths virtualPaths;
          packages = with pkgs; [
            watch-script
            # hayagriva
            # pandoc
            # pandoc-lua-filters
            # pandoc-include
            # pandoc-tablenos
            # pandoc-katex
            # pandoc-imagine
            # imagemagick
          ];
        };
        apps = {
          default = config.apps.watch;
          build = { type = "app"; program = build-script; };
          watch = { type = "app"; program = watch-script; };
        };
        _module.args.typix = inputs.typix.lib.${system};
      };
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    fmway-nix.url = "github:fmway/fmway.nix";
    fmway-nix.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    typix.url = "github:loqusion/typix";
    typix.inputs.nixpkgs.follows = "nixpkgs";
    systems.url = "github:nix-systems/default";
  };
}
