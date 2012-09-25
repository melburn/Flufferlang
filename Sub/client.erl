-module(client).
-compile(export_all).

start() ->
	spawn(?MODULE, loop, []).
request(Pid, []) ->
	[];

request(Pid, [L|ListOfDocuments]) ->
	{One, Two} = L,
	T = request(self(), ListOfDocuments),
	gsserver ! {self(), 1337, One, Two},
	receive
		{ok, 1337, Document} ->
			H = Document;
		{error, 1337} ->
			H = fail
	end,
	[H|T].	



loop() ->
	receive
		{From, Data} ->
			From ! Data,
			loop()
	end.

