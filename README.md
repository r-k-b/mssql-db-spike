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

Q: will something like `strace -ff -tt sh -c 'result/bin/mssqlscripter -S foo' 1>strace_combined.txt 2>&1` help?

A: Yep, searched for `libssl` in that text, saw it was looking for `libssl.so.1.0.2` in a bunch of places, while we're
supplying `libssl.so.1.1`.

Looks like there's an open issue for this against the scripter:
<https://github.com/microsoft/mssql-scripter/issues/236>

Should we drop the included sqltools binaries, build them ourselves? Will that fix it?
<https://microsoft.github.io/sqltoolssdk/guide/building_sqltoolsservice.html>

Or should we give in, allow it to have the unsafe OpenSSL 1.0.2?

---

Q: do we need to extract the tar files during the buildPhase or installPhase?


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
