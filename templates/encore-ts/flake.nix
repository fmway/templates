{
  description = "Encore Typescript Starter";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    fmway-lib.url = "github:fmway/lib";
    fmway-lib.inputs.nixpkgs.follows = "nixpkgs";
    fmway-modules.url = "github:fmway/modules";
    fmway-modules.inputs.fmway-lib.follows = "fmway-lib";
    flake-parts.url = "github:hercules-ci/flake-parts";
    encore.url = "github:encoredev/encore-flake";
    encore.inputs.nixpkgs.follows = "nixpkgs";
    systems.url = "github:nix-systems/default";
  };

  outputs = { fmway-lib, ... } @ inputs:
  fmway-lib.lib.mkFlake { inherit inputs; } ({ lib, ... }: {
    perSystem = { pkgs, system, ... }: {
      devShells.default = pkgs.mkShellNoCC {
        buildInputs = with pkgs; [
          encore
          nodejs_latest
          yarn-berry
        ];
        shellHook = ''
          if ! [ -f ".encore/manifest.json" ]; then
            local_id="$(tr -dc A-Za-z0-9 </dev/urandom | head -c 5; echo)"
            [ -d ".encore" ] || mkdir ".encore"
            echo '{"local_id":"'$local_id'","tutorial":""}' > .encore/manifest.json
          fi
        '';
      };

      nixpkgs.config.packageOverrides = pkg: {
        encore = inputs.encore.packages.${system}.encore;
      };
    };
  });
}
