# What's this about?

What does it take to create minimal copies of the app databases?

What does it take to spin up a minimal "config server"?

# todo

## sqlclient unable to load System.Net.Security.Native

Why does this happen?

```
$ mssqlscripter -S phdccwestdev -d paragon
Scripting request: 43707677-4123-45f4-940a-c8baa2e03bff encountered error: Failed to connect to server phdccwestdev.
Error details: Microsoft.SqlServer.Management.Common.ConnectionFailureException: Failed to connect to server phdccwestdev. ---> System.Data.SqlClient.SqlException: Unable to load shared library 'System.Net.Security.Native' or one of its dependencies. In order to help diagnose loading problems, consider setting the LD_DEBUG environment variable: libSystem.Net.Security.Native: cannot open shared object file: No such file or directory
   at Interop.NetSecurityNative.ImportPrincipalName(Status& minorStatus, String inputName, Int32 inputNameByteCount, SafeGssNameHandle& outputName)
   at Microsoft.Win32.SafeHandles.SafeGssNameHandle.CreatePrincipal(String name)
   at System.Net.Security.SafeDeleteNegoContext..ctor(SafeFreeNegoCredentials credential, String targetName)
   at System.Net.Security.NegotiateStreamPal.EstablishSecurityContext(SafeFreeNegoCredentials credential, SafeDeleteContext& context, String targetName, ContextFlagsPal inFlags, SecurityBuffer inputBuffer, SecurityBuffer outputBuffer, ContextFlagsPal& outFlags)
   at System.Net.Security.NegotiateStreamPal.InitializeSecurityContext(SafeFreeCredentials credentialsHandle, SafeDeleteContext& securityContext, String spn, ContextFlagsPal requestedContextFlags, SecurityBuffer[] inSecurityBufferArray, SecurityBuffer outSecurityBuffer, ContextFlagsPal& contextFlags)
   at System.Data.SqlClient.SNI.SNIProxy.GenSspiClientContext(SspiClientContextStatus sspiClientContextStatus, Byte[] receivedBuff, Byte[]& sendBuff, Byte[] serverName)
   at System.Data.SqlClient.SNI.TdsParserStateObjectManaged.GenerateSspiClientContext(Byte[] receivedBuff, UInt32 receivedLength, Byte[]& sendBuff, UInt32& sendLength, Byte[] _sniSpnBuffer)
   at System.Data.SqlClient.TdsParser.SNISSPIData(Byte[] receivedBuff, UInt32 receivedLength, Byte[]& sendBuff, UInt32& sendLength)
   at System.Data.SqlClient.SqlInternalConnectionTds..ctor(DbConnectionPoolIdentity identity, SqlConnectionString connectionOptions, SqlCredential credential, Object providerInfo, String newPassword, SecureString newSecurePassword, Boolean redirectedUserInstance, SqlConnectionString userConnectionOptions, SessionData reconnectSessionData, Boolean applyTransientFaultHandling)
   at System.Data.SqlClient.SqlConnectionFactory.CreateConnection(DbConnectionOptions options, DbConnectionPoolKey poolKey, Object poolGroupProviderInfo, DbConnectionPool pool, DbConnection owningConnection, DbConnectionOptions userOptions)
   at System.Data.ProviderBase.DbConnectionFactory.CreatePooledConnection(DbConnectionPool pool, DbConnection owningObject, DbConnectionOptions options, DbConnectionPoolKey poolKey, DbConnectionOptions userOptions)
   at System.Data.ProviderBase.DbConnectionPool.CreateObject(DbConnection owningObject, DbConnectionOptions userOptions, DbConnectionInternal oldConnection)
   at System.Data.ProviderBase.DbConnectionPool.UserCreateRequest(DbConnection owningObject, DbConnectionOptions userOptions, DbConnectionInternal oldConnection)
   at System.Data.ProviderBase.DbConnectionPool.TryGetConnection(DbConnection owningObject, UInt32 waitForMultipleObjectsTimeout, Boolean allowCreate, Boolean onlyOneCheckConnection, DbConnectionOptions userOptions, DbConnectionInternal& connection)
   at System.Data.ProviderBase.DbConnectionPool.TryGetConnection(DbConnection owningObject, TaskCompletionSource`1 retry, DbConnectionOptions userOptions, DbConnectionInternal& connection)
   at System.Data.ProviderBase.DbConnectionFactory.TryGetConnection(DbConnection owningConnection, TaskCompletionSource`1 retry, DbConnectionOptions userOptions, DbConnectionInternal oldConnection, DbConnectionInternal& connection)
   at System.Data.ProviderBase.DbConnectionInternal.TryOpenConnectionInternal(DbConnection outerConnection, DbConnectionFactory connectionFactory, TaskCompletionSource`1 retry, DbConnectionOptions userOptions)
   at System.Data.SqlClient.SqlConnection.TryOpen(TaskCompletionSource`1 retry)
   at System.Data.SqlClient.SqlConnection.Open()
   at Microsoft.SqlServer.Management.Common.ConnectionManager.InternalConnect()
   at Microsoft.SqlServer.Management.Common.ConnectionManager.Connect()
   --- End of inner exception stack trace ---
   at Microsoft.SqlServer.Management.Common.ConnectionManager.Connect()
   at Microsoft.SqlServer.Management.Common.ConnectionManager.PoolConnect()
   at Microsoft.SqlServer.Management.Common.ConnectionManager.GetServerInformation()
   at Microsoft.SqlServer.Management.Smo.Server.IsAzureDbScopedConnection(ServerConnection sc)
   at Microsoft.SqlServer.Management.Smo.Server.GetExecutionManager()
   at Microsoft.SqlServer.Management.Smo.SqlSmoObject.get_ServerVersion()
   at Microsoft.SqlServer.Management.Smo.Server.get_Version()
   at Microsoft.SqlServer.Management.SqlScriptPublish.SqlScriptPublishModel.GetAdvancedScriptingOptions()
   at Microsoft.SqlTools.ServiceLayer.Scripting.ScriptingScriptOperation.BuildPublishModel() in D:\repos\sqltoolsservice\src\Microsoft.SqlTools.ServiceLayer\Scripting\ScriptingScriptOperation.cs:line 138
   at Microsoft.SqlTools.ServiceLayer.Scripting.ScriptingScriptOperation.Execute() in D:\repos\sqltoolsservice\src\Microsoft.SqlTools.ServiceLayer\Scripting\ScriptingScriptOperation.cs:line 42
```


## unsafe OpenSSL

work out how to properly fix the error:

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


## tarfiles phase question

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
