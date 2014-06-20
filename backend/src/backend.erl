-module(backend).

-export([start/0, start/2, stop/1]).

start() ->
    start(normal, []).

start(_Type, _) ->
    {ok, _Pid} = db_sup:start_link().

stop(_State) ->
    ok.

