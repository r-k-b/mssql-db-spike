{ pkgs }:
let version = "1.0.0a23";
 p3p = pkgs.python3Packages;
in with pkgs; p3p.buildPythonPackage {
  pname = "mssql-scripter";
  inherit version;

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "mssql-scripter";
    rev = "v" + version;
    sha256 = "0xb4yhqizsdbfrg5hh96phb4ghxrzln3kkkblbkvqah05jrk2cm6";
  };

  checkInputs = with p3p; [ pytest ];

  checkPhase = ''
    pytest
  '';

  dontUsePythonRecompileBytecode = true;

  propagatedBuildInputs = with p3p; [ bash future ];

  meta = {
    homepage = "https://github.com/Microsoft/mssql-scripter/";
    description = "Microsoft SQL Scripter Command-Line Tool";
    license = lib.licenses.mit;
    #maintainers = with lib.maintainers; [ rkb ];
  };
}

