# What's this about?

What does it take to create minimal copies of the app databases?

What does it take to spin up a minimal "config server"?

# todo

work out how to fix the error:

```
$ result/bin/mssqlscripter -S wef
No usable version of the libssl was found
Scripting request: 1 encountered error: Scripting request encountered a exception
Error details: ('End of stream reached, no output.',)
```

will something like `strace -ff -tt sh -c 'result/bin/mssqlscripter -S foo' 1>strace_combined.txt 2>&1` help? 

do we need to extract the tar files during the buildPhase or installPhase?


# debugging

## just the results

Produces a `result` symlink to the build results.

```shell
$ nix-build .
```

Auto-rebuilding equivalent:

```shell
$ ag -g *.nix -l | entr nix-build .
```

## step through each Phase interactively

It's sadly fiddly to step through a build with nix-shell. It should be run in a clean build folder, but nix-shell
doesn't set that up for us.
It should also be pointed to a clean "output" folder, but same deal, gotta set that up ourselves.
The `./debug-nix-shell.sh` script is helper for those problems, and shows one way to set up a clean environment for
nix-shell work.

See Also: <https://nixos.org/guides/nix-pills/developing-with-nix-shell.html>

```shell
$ ./debug-nix-shell.sh

$ type genericBuild

$ echo $phases

$ eval "$unpackPhase"

$ cd $out

$ eval "$fixupPhase"
```
