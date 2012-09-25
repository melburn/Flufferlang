-module(gsserv).
-compile(export_all).

start() ->
	try
		Pid = spawn(?MODULE, loop, []),
		register(gsserver, Pid)
	catch
		_:_ -> error
	end.

stop() ->
	unregister(gsserver),
	exit(self(), kill).

loop() ->
	ImgPid = imgserver:start(),
	DocPid = docserver:Start(),
	DBPid = dbserver:start(),
	loop(ImgPid, DocPid, DBPid);

loop(ImgPid, DocPid, DBPid) -> 
receive
		{Pid, Ref, Tag, Data} ->
			case Tag of
				img -> imgcall(ImgPid, {Pid, Ref, Tag, Data});
				doc -> doccall(DocPid, {Pid, Ref, Tag, Data});
				dbquery -> dbcall(DBPid, {Pid, Ref, get, Data})
			end,
			loop(ImgPid, DocPid, DBPid);
		{ok, {Pid, Ref}, {Name, L}} ->
			;
		{ok, {Pid, Ref}, [H|T]} ->
			;
		{ok, {Pid, Ref}, V} ->

end.

imgcall(ImgPid, {Pid, Ref, Tag, {Imgname, W, H}}) ->
	.

doccall(DocPid, {Pid, Ref, Tag, Data}) ->
	.

dbcall(DBPid, {Pid, Ref, Tag, Data}) ->
	.
