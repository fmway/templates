{ config, pkgs, ... }:
{
  languages.rust = {
    enable = true;
    channel = "nightly";
    components = [ "rustc" "cargo" "clippy" "rustfmt" "rust-analyzer" ];
  };

  enterShell = /* sh */ ''
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
}
