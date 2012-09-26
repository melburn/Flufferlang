-module(gsserv).
-compile(export_all).

start() ->
	try
		Pid = spawn(?MODULE, loop, []),
		register(gsserver, Pid)
	catch
		_:_ -> error_start
	end.

stop() ->
	try
		unregister(gsserver),
		exit(self(), kill)
	catch
		_:_ -> error_stop
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
				img -> imgcall(ImgPid, {Pid, Ref, get, Data});
				doc -> doccall(DocPid, {Pid, Ref, get, Data});
				dbquery -> dbcall(DBPid, {Pid, Ref, get, Data})
			end,
			loop(ImgPid, DocPid, DBPid);
		{ok, {Pid, Ref}, {Text, L}} ->
			dbreceive(ok, Pid, Ref, Text, L),
			loop(ImgPid, DocPid, DBPid);
		{ok, {Pid, Ref}, [H|T]} ->
			docreceive(ok, Pid, Ref, [H|T]),
			loop(ImgPid, DocPid, DBPid);
		{ok, {Pid, Ref}, Data} ->
			imgreceive(ok, Pid, Ref, Data),
			loop(ImgPid, DocPid, DBPid);
		L -> error_answer_from_servers
end.

imgcall(ImgPid, {Pid, Ref, Tag, {Imgname, W, H}}) ->
	ImgPid ! {self(), {Pid, Ref}, Tag, Imgname, W, H}.

doccall(DocPid, {Pid, Ref, Tag, Data}) ->
	DocPid ! {self(), {Pid, Ref}, Tag, Data}.

dbcall(DBPid, {Pid, Ref, Tag, Data}) ->
	DBPid ! {self(), {Pid, Ref}, Tag, Data}.
	
imgreceive(ok, Pid, Ref, Data) ->
	Pid ! {ok, Ref, {img, Data}}.
	
docreceive(ok, Pid, Ref, L) ->
	Pid ! {ok, Ref, {doc, L}}.
	
dbreceive(ok, Pid, Ref, Text, L) ->
	Pid ! {ok, Ref, {doc, [{text, Text}|L]}}.
