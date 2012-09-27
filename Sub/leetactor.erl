-module(leetactor).
-compile(export_all).

start() ->
	spawn(?MODULE, loop, []).

loop() ->
	receive
		{ClientPid, Ref, Tag, Data, ContentPid} ->
			case Tag of
				img ->
					{Name, W, H} = Data,
					ContentPid ! {self(), Ref, get, Name, W, H};
				_ ->
					ContentPid ! {self(), Ref, get, Data}	
			end,
			io:fwrite("1"),
			receive
				{ok, Ref, {Text, L}} ->
					dbreceive(ok, ClientPid, Ref, Text, L);
				{ok, Ref, [Head|Tail]} ->
					docreceive(ok, ClientPid, Ref, [Head|Tail]);
				{ok, Ref, D} ->
					io:fwrite("2"),
					imgreceive(ok, ClientPid, Ref, D)
			end,
		loop()
	end.


imgreceive(ok, Pid, Ref, Data) ->
	Pid ! {ok, Ref, {img, Data}}.
	
docreceive(ok, Pid, Ref, L) ->
	Pid ! {ok, Ref, {doc, L}}.
	
dbreceive(ok, Pid, Ref, Text, L) ->
	Pid ! {ok, Ref, {doc, [{text, Text}|workDB(L)]}}.
	
workDB([]) ->
	[];
	
workDB([H|T]) ->
	[{dbquery, H}|workDB(T)].
