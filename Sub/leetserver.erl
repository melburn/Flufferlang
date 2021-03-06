-module(leetserver).
-compile(export_all).

start() ->
	try
		Pid = spawn(?MODULE, loop, []),
		register(gsserver, Pid)
	catch
		_:_ -> error_start
	end.

stop() ->
	Ref = monitor(process, gsserver),
	try
		gsserver ! stop,
		receive
			{'DOWN', Ref, process, {gsserver, _},_} ->
				{ok, stopped}
		after 3000 ->
				exit(whereis(gsserver), kill),
				receive
					{'DOWN', Ref, process, _, _} ->
						{ok, killed}
				after 3000 ->
						demonitor(Ref, [flush]),
						{error, timeout}
				end
		end		
	catch
	_:_ ->
		demonitor(Ref, [flush]),
		{error, timeout}
	end.

loop() ->
	ImgPid = imgserver:start(),
	DocPid = docserver:start(),
	DBPid = dbserver:start(),
	loop(ImgPid, DocPid, DBPid).

loop(ImgPid, DocPid, DBPid) -> 
receive
	{Pid, Ref, Tag, Data} ->
		case Tag of
			img -> imgcall(ImgPid, {Pid, Ref, Tag, Data});
			doc -> doccall(DocPid, {Pid, Ref, Tag, Data});
			dbquery -> dbcall(DBPid, {Pid, Ref, Tag, Data})
		end,
		loop(ImgPid, DocPid, DBPid)
end.

imgcall(ImgPid, {Pid, Ref, Tag, {Imgname, W, H}}) ->
	ActorPid = leetactor:start(),
	ActorPid ! {Pid, Ref, Tag, {Imgname, W, H}, ImgPid}.
	
doccall(DocPid, {Pid, Ref, Tag, Data}) ->
	ActorPid = leetactor:start(),
	ActorPid ! {Pid, Ref, Tag, Data, DocPid}.

dbcall(DBPid, {Pid, Ref, Tag, Data}) ->
	ActorPid = leetactor:start(),
	ActorPid ! {Pid, Ref, Tag, Data, DBPid}.
