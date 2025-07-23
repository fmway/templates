{
  description = "Devenv + flake-parts for rust development";

  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    fmway-lib.url = "github:fmway/lib";
    fmway-modules.url = "github:fmway/modules";
    systems.url = "github:nix-systems/default";
    rust-overlay.url = "github:oxalica/rust-overlay";

    fmway-lib.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    fmway-modules.inputs.fmway-lib.follows = "fmway-lib";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, fmway-lib, ... }:
  fmway-lib.mkFlake { inherit inputs; } {
    perSystem = { config, lib, pkgs, system, ... }: {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          rustToolchain
          openssl
          pkg-config
          cargo-deny
          cargo-edit
          cargo-watch
          rust-analyzer
          cargo-generate
        ];

        shellHook = /* bash */ ''
          if ! [ -e Cargo.toml ]; then
            cargo init

            # add some file to gitignore
            ignores=( ".devenv*" "devenv.local.nix" ".direnv" ".pre-commit-config.yaml" )
            gitignore="$(cat .gitignore 2>/dev/null)"
            for i in "''${ignores[@]}"; do
              echo "$gitignore" | grep "$i" &>/dev/null || echo "$i" >> .gitignore
            done
          fi
        '';

        env = {
          # Required by rust-analyzer
          RUST_SRC_PATH = "${pkgs.rustToolchain}/lib/rustlib/src/rust/library";

          NIXD_PATH = lib.concatStringsSep ":" [
            "pkgs=${self.outPath}#legacyPackages.${system}"
          ];
        };
      };
      nixpkgs.overlays = with inputs; [
        rust-overlay.overlays.default
        (self: super: {
          rustToolchain = self.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        })
      ];
    };
  };
}
