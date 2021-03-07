{ pkgs }:
let
  version = "1.0.0a23";
  p3p = pkgs.python3Packages;
  inherit (pkgs)
    at-spi2-atk at-spi2-core atomEnv curl fetchFromGitHub icu kerberos lib
    libunwind libuuid makeWrapper openssl_1_0_2 stdenv zlib;

  edition = "mssql-scripter";
  targetPath = "$out/${edition}";

  sqlToolsServiceRpath = lib.makeLibraryPath [
    curl
    icu
    libunwind
    libuuid
    openssl_1_0_2
    stdenv.cc.cc
    zlib
  ];

  sqlToolsServicePath = "mssqlscripter/mssqltoolsservice/bin";

  rpath = lib.concatStringsSep ":" [
    atomEnv.libPath
    (lib.makeLibraryPath [
      at-spi2-atk
      at-spi2-core
      kerberos
      libuuid
      stdenv.cc.cc.lib
    ])
    targetPath
    sqlToolsServiceRpath
  ];
in stdenv.mkDerivation {
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

  nativeBuildInputs = with pkgs; [ rsync makeWrapper ];

  propagatedBuildInputs = with p3p; [ future ];

  phases = "unpackPhase fixupPhase";

  unpackPhase = ''
    # what folder are we expected to be in right now?
    # is it different between nix-shell and nix-build?
    echo pwd=$PWD
    touch ./THIS_CAME_FROM_OUR_UNPACKPHASE

    mkdir -p $out/bin
    mkdir -p $out/${sqlToolsServicePath}
    rsync -rlx --chmod=+w --exclude sqltoolsservice $src/ $out/
    tar -xf $src/sqltoolsservice/manylinux1/Microsoft.SqlTools.ServiceLayer-linux-x64-netcoreapp2.1.tar.gz \
        -C $out/${sqlToolsServicePath}
  '';

  fixupPhase = ''
    makeWrapper ${p3p.python.interpreter} $out/bin/mssqlscripter \
      --set PYTHONPATH "$PYTHONPATH:$out" \
      --add-flags "-O $out/mssqlscripter/main.py"

    fix_sqltoolsservice()
    {
      mv $out/${sqlToolsServicePath}/$1 $out/${sqlToolsServicePath}/$1_old
      patchelf \
        --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" \
        $out/${sqlToolsServicePath}/$1_old
      makeWrapper \
        $out/${sqlToolsServicePath}/$1_old \
        $out/${sqlToolsServicePath}/$1 \
        --set LD_LIBRARY_PATH ${sqlToolsServiceRpath}
    }
    fix_sqltoolsservice MicrosoftSqlToolsServiceLayer

    # not required for mssql-scripter? only azuredatastudio?
    #fix_sqltoolsservice MicrosoftSqlToolsCredentials
    #fix_sqltoolsservice SqlToolsResourceProviderService


    # do we need to set interpreter/cc/something like this? (copied from the azuredatastudio example)"
    #patchelf \
    #  --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" \
    #  ${targetPath}/${edition}

    # makeWrapper \
    #   ${targetPath}/bin/${edition} \
    #   $out/bin/foo \
    #   --set LD_LIBRARY_PATH ${rpath}
  '';

  meta = {
    homepage = "https://github.com/Microsoft/mssql-scripter/";
    description = "Microsoft SQL Scripter Command-Line Tool";
    license = lib.licenses.mit;
  };
}
