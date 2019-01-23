let
  pkgsJSON = builtins.fromJSON (builtins.readFile ./nixpkgs.json);
  pypi2nixJSON = builtins.fromJSON (builtins.readFile ./pypi2nix.json); 
  pkgsSrc = builtins.fetchTarball { inherit (pkgsJSON) url sha256; };
  pypi2nixSrc = builtins.fetchTarball { inherit (pypi2nixJSON) url sha256; };
  overlay = self: super: {
    pypi2nix = import pypi2nixSrc { pkgs = self; };
  };
in
{ pkgs ? import pkgsSrc { config = {}; overlays = [ overlay ]; }
}:

let
  python = import ./requirements.nix { inherit pkgs; };
  version = builtins.replaceStrings ["\n"] [""]
    (builtins.readFile (toString ../version.txt));

  self = python.mkDerivation rec {
    name = "configloader-${version}";
    src = builtins.filterSource pkgs.lib.cleanSourceFilter ../.;
    doCheck = false;
    buildInputs = builtins.attrValues python.packages;
    propagatedBuildInputs = with python.packages; [
      Click
      json-e
      PyYAML
    ];

    passthru = {
      inherit python;

      # to update the dependencies run the following 2 commands:
      # nix-build -A update
      # ./result
      update = pkgs.writeScript "update-${self.name}" ''
        pushd ${toString ./.}
        ${pkgs.pypi2nix}/bin/pypi2nix \
          -V 3.7 \
          -r ../requirements.txt
      '';

    };

  };

in self
