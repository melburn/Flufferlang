-module(client).
-compile(export_all).

start() ->
	spawn_link(?MODULE, loop, []).
request(_Pid, []) ->
	[];

request(_Pid, [L|ListOfDocuments]) ->
	{One, Two} = L,
	T = request(self(), ListOfDocuments),
	gsserver ! {self(), 1337, One, Two},
	receive
		{ok, 1337, Document} ->
			H = Document;
		{error, 1337} ->
			H = fail
	end,
	lists:append(work(H), T).

work({text, Data}) ->
	[{text, Data}];
	
work({dbquery, Data}) ->
	gsserver ! {self(), 1338, dbquery, Data},
	receive
		{ok, 1338, Return} ->
			work(Return);
		{error, 1338} ->
			error
	end;
	
work({img, {Name, Height, Width}}) ->
	gsserver ! {self(), 1336, img, {Name, Height, Width}},
	receive
		{ok, 1336, Return} ->
			work(Return);
		{error, 1336} ->
			error
	end;
	
work({img, Data}) ->
	[{img, Data}];
	
work({doc, []}) ->
	[];
	
work({doc, [{Tag, Data}|T]}) ->
	NewH = work({Tag, Data}),
	NewT = work({doc, T}),
	lists:append(NewH,NewT);

work({doc, Data}) ->
	gsserver ! {self(), 1339, doc, Data},
	receive
		{ok, 1339, Return} ->
			work(Return);
		{error, 1339} ->
			error
	end.
	
%work(A) ->
%	io:fwrite("lol2"),
%	[A].


loop() ->
	receive
		{From, Data} ->
			From ! Data,
			loop()
	end.

