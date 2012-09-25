-module(gsserv).
-compile(export_all).

start() ->
	Pid = spawn(?MODULE, loop, []),
	register(gsserver, Pid).

stop() ->
	unregister(gsserver),
	exit(self(), kill).

request() ->
	3.

loop() ->
	receive
		{Pid, Ref, Tag, Data} ->
			Pid ! {ok, Ref, Data},
			loop()
end.
