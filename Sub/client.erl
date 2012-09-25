-module(client).
-compile(export_all).

start() ->
	spawn(?MODULE, loop, []).
request(Pid, []) ->
	[];

request(Pid, [L|ListOfDocuments]) ->
	{One, Two} = L,
	T = request(self(), ListOfDocuments),
	server ! {self(), 1337, One, Two},
	receive
		H ->
			H
	end,
	[H|T].	



loop() ->
	receive
		{From, Data} ->
			From ! Data,
			loop()
	end.

