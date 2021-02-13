let
  pkgs = import <nixpkgs> { };

  mssql-scripter = (import ./mssql-scripter.nix) { inherit pkgs; };

in pkgs.mkShell {
  name = "webdev";

  buildInputs = with pkgs; [
    docker
    docker-compose
    mssql-scripter
    dos2unix
    nodejs
    steam-run
  ];
}

