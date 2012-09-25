-module(gsserv).
-compile(export_all).

start() ->
	Pid = spawn(?MODULE, loop, []),
	register(server, Pid).

stop() ->
	unregister(server),
	exit(self(), kill).

request() ->
	3.

loop() ->
	receive
		{Pid, Ref, Tag, Data} ->
			Pid ! Data,
			loop()
end.
