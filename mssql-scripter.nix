{ pkgs }:
let
  version = "1.0.0a23";
  p3p = pkgs.python3Packages;
in with pkgs;
p3p.buildPythonApplication {
  pname = "mssql-scripter";
  inherit version;

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "mssql-scripter";
    rev = "v" + version;
    sha256 = "0xb4yhqizsdbfrg5hh96phb4ghxrzln3kkkblbkvqah05jrk2cm6";
  };

  # About patching the MS service layer binaries, See Also:
  # <https://github.com/NixOS/nixpkgs/blob/63bffaf22799bef43d23112f9065a207bf3aef24/pkgs/applications/misc/azuredatastudio/default.nix#L52>

  propagatedBuildInputs = with p3p; [ future ];

  checkPhase = "exit 0";

  installPhase = ''
    mkdir -p ./temp-home
    export HOME=./temp-home
    mkdir -p "$out"/{bin,src}
    cp -R * $out/src

    # don't need to keep the archive files in the closure
    rm -rf $out/src/sqltoolsservice

    mkdir -p $out/src/mssqlscripter/mssqltoolsservice/bin
    tar -xvf sqltoolsservice/manylinux1/Microsoft.SqlTools.ServiceLayer-linux-x64-netcoreapp2.1.tar.gz \
        -C $out/src/mssqlscripter/mssqltoolsservice/bin

    makeWrapper ${python3Packages.python.interpreter} $out/bin/mssql-scripter \
      --set PYTHONPATH "$PYTHONPATH:$out/src" \
      --add-flags "-O $out/src/mssqlscripter/main.py"
  '';

  meta = {
    homepage = "https://github.com/Microsoft/mssql-scripter/";
    description = "Microsoft SQL Scripter Command-Line Tool";
    license = lib.licenses.mit;
  };
}

