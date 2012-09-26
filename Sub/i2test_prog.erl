-module(i2test_prog).

-compile(export_all).

setup(InterfaceModule) ->
    InterfaceModule:stop(),
    InterfaceModule:start().

test(NumClients) ->
    {ok,TestData} = file:consult("testdata.dat"),
    Q = [ Q || {Q,_} <- TestData ],
    R = [ R || {_,R} <- TestData ],
    Clients = [ spawn_link(?MODULE,tester,[self(),Q]) || _ <- lists:seq(1,NumClients) ],
    collect(ready,NumClients),
    [ C ! go || C <- Clients ],
    collect(R,NumClients),
    ok.

collect(_,0) ->
    ok;
collect(What,N) ->
    receive
	What ->
	    collect(What,N-1);
	Other ->
	    exit({got_unexpected,Other})
    end.

tester(Parent,Q) ->
    Cli = client:start_link(),
    Parent ! ready,
    receive
	go ->
	    Parent ! client:request(Cli,Q)
    end.
