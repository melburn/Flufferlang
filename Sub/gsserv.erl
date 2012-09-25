-module(gsserv).
-compile(export_all).

start() ->
	Pid = spawn(?MODULE, loop, []),
	register(gsserver, Pid).

stop() ->
	unregister(gsserver),
	exit(self(), kill).

loop() ->
	receive
		{Pid, Ref, Tag, Data} ->
			case Tag of
				img -> imgserver ! {Pid, Ref, Tag, Data};
				doc -> docserver 1 {Pid, Ref, Tag, Data};
				dbquery -> dbserver ! {Pid, Ref, get, Data}
			end.
			loop()
end.
