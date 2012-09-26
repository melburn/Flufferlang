-module(client).
-compile(export_all).

<<<<<<< HEAD
start() ->
	spawn_link(?MODULE, loop, []).
request(_Pid, []) ->
	[];
=======
start_link() ->
	spawn(?MODULE, loop, []).
>>>>>>> 670a86a07bcce58288c2969a2a7e133d543c6242

request(Pid, ListOfDocuments) ->
	Pid ! {self(), daRef, ListOfDocuments},
	receive
		{ok, daRef, ListofAnswers} ->
			ListofAnswers;
		_ ->	
			error
	end.

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
	end;

work([]) ->
	[];

work([H|T]) ->
	T2 = work(T),
	[work({doc, H})| T2].

loop() ->
	receive
		{Pid, Ref, Data} ->
			Pid ! {ok, Ref, work(Data)},
			loop();
		_ ->
			badType
	end.

