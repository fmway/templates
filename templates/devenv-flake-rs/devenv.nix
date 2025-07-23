{ config, pkgs, ... }:
{
  languages.rust = {
    enable = true;
    channel = "nightly";
    components = [ "rustc" "cargo" "clippy" "rustfmt" "rust-analyzer" ];
  };

  enterShell = /* sh */ ''
    if ! [ -d target ]; then
      cargo init
      mkdir target

      # add some file to gitignore
      echo ".devenv*" >> .gitignore
      echo "devenv.local.nix" >> .gitignore
      echo ".direnv" >> .gitignore
      echo ".pre-commit-config.yaml" >> .gitignore
    fi
  '';
}
