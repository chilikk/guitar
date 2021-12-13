-module(guitar_sup).

-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    GuitarDB = #{id => guitar_db,
                 start => {guitar_db, start_link, []}},
    {ok, {#{}, [GuitarDB]}}.
