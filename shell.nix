let

#  overlay = self: super: {
#    python3 = super.python3 {
#      #packageOverrides = python-self: python-super: {
#        mssql-scripter = super.python3.callPackage ./mssql-scripter.nix { };
#      #};
#    };
#  };

  pkgs = import <nixpkgs> { };

  mssql-scripter = (import ./mssql-scripter.nix) { inherit pkgs; };

  pypkgs = python-packages: with python-packages; [ mssql-scripter databricks-cli ];
  mypython = pkgs.python3.withPackages pypkgs;

in pkgs.mkShell {
  name = "webdev";

  buildInputs = with pkgs; [
    docker
    docker-compose
    mypython
    python38Packages.pip
    dos2unix
    nodejs
    steam-run
  ];
}

