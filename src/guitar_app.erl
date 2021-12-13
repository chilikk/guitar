-module(guitar_app).

-export([start/2, stop/1]).

-define(CSS_DIR, filename:join(code:priv_dir(guitar), "css")).
-define(JS_DIR, filename:join(code:priv_dir(guitar), "js")).

start(_, _) ->
    Dispatch = cowboy_router:compile(
                 [{'_', [{"/", guitar_handler, []},
                         {"/song", guitar_handler, []},
                         {"/admin", guitar_handler, []},
                         {"/admin/edit", guitar_handler, []},
                         {"/admin/op", guitar_handler, []},
                         {"/css/[...]", cowboy_static, {dir, ?CSS_DIR}},
                         {"/js/[...]", cowboy_static, {dir, ?JS_DIR}}
                        ]}]
                ),
    {ok, _} = cowboy:start_clear(guitar, [{port, 8080}],
                                 #{env => #{dispatch => Dispatch}}),
    guitar_sup:start_link().

stop(_) ->
    ok.
