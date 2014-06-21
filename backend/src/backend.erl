-module(backend).

-export([start/0, start/2, stop/1]).

start() ->
    {ok, Pid} = start(normal, []),
    unlink(Pid).

start(_Type, _) ->
    {ok, _Pid} = db_sup:start_link().

stop(_State) ->
    ok.
