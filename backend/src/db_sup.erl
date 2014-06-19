-module(db_sup).
-behaviour(supervisor).
-export([init/1]).

-export([start/2, stop/1]).

init([]) ->
    Db = {db, {db, start_link, []}, permanent, 5, worker, [db]},
    {ok, {{one_for_one, 2, 60}, [Db]}}.

start(_Type, _) ->
    {ok, _Pid} = supervisor:start_link({local, ?MODULE}, ?MODULE, []).

stop(_State) ->
    ok.
