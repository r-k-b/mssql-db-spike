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

  propagatedBuildInputs = with p3p; [ future ];

  checkPhase = "exit 0";

  installPhase = ''
    mkdir -p ./temp-home
    export HOME=./temp-home
    mkdir -p "$out"/{bin,src}
    cp -R * $out/src

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

