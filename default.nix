let nixpkgs = import <nixpkgs> { };
in nixpkgs.callPackage ./mssql-scripter.nix { pkgs = nixpkgs; }
