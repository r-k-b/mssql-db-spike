set -euo pipefail

scriptDir=$(dirname "$(readlink -f "$0")")

cd "$scriptDir"

printf "Clearing previous temp folders... "
rm -rf shellTmp
rm -rf shellOutput
echo done.

mkdir -p shellTmp

cd shellTmp

cat << EOF

Tip: try running: eval "\$unpackPhase"

And after that succeeds, run:
$ cd \$out

and perhaps:
$ eval "\$fixupPhase"
EOF

nix-shell --command "export out=$scriptDir/shellOutput; return" .. --pure
