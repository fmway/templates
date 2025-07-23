{
  inputs = {
    fmway-lib.url = "github:fmway/lib";
  };

  outputs = { fmway-lib, self, ... } @ inputs: let
    inherit (fmway-lib) lib;
  in {
    # FIXME use static gen instead of auto import
    templates = let
      dir = ./templates;
      list = with lib; attrNames (
        filterAttrs (k: _: pathIsDirectory "${dir}/${k}") (
          builtins.readDir dir
        )
      );
    in lib.mapListToAttrs (name: {
      inherit name;
      value = let
        path = "${dir}/${name}";
        description = (import "${path}/flake.nix").description or "";
      in { inherit path; } // lib.optionalAttrs (lib.pathIsRegularFile "${path}/flake.nix") { inherit description; };
    }) list;
  };
}
