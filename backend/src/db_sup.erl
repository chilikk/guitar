-module(db_sup).
-behaviour(supervisor).
-export([init/1, start_link/0]).

init([]) ->
    Db = {db, {db, start_link, []}, permanent, 5, worker, [db]},
    {ok, {{one_for_one, 2, 60}, [Db]}}.

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

