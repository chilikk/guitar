-module(db).
-vsn("2.0").
-behaviour(gen_server).

-include("song.hrl").
-include("db.hrl").

-export([init/1, terminate/2,
         handle_call/3, handle_info/2, handle_cast/2,
         code_change/3]).

-export([start_link/0, save_text/3, get_text/2,
                       save_chords/3, get_chords/2,
                       get_keys/0,
                       delete_song/2]).

%% gen_server exports

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init(_) ->
    {ok, ?SONGDB} = dets:open_file(?SONGDB, [{file, ?SONGDBFILE}]),
    {ok, ?CHORDDB} = dets:open_file(?CHORDDB, [{file, ?CHORDDBFILE}]),
    error_logger:info_msg("starting db~n", []),
    {ok, []}.

terminate(Reason, _) ->
    ok = dets:close(?SONGDB),
    ok = dets:close(?CHORDDB),
    error_logger:info_msg("stopping db because of: ~p~n", [Reason]),
    ok.

handle_call({save_text, Song}, _From, State) ->
    Res = dets:insert(?SONGDB,
                      {{Song#song.author, Song#song.title}, Song#song.text}),
    {reply, Res, State};

handle_call({delete_song, Song}, _From, State) ->
    Res = dets:delete(?SONGDB, {Song#song.author, Song#song.title}),
    {reply, Res, State};

handle_call({get_text, Song}, _From, State) ->
    Key = {Song#song.author, Song#song.title},
    {reply,
     case dets:lookup(?SONGDB, Key) of
        [{_, Value} | _] -> {ok, Song#song{text = Value}};
        _ -> {error, not_found}
     end,
     State};

handle_call({save_chords, Song}, _From, State) ->
    Res = dets:insert(?CHORDDB,
                {{Song#song.author, Song#song.title}, Song#song.chords}),
    {reply, Res, State};

handle_call({get_chords, Song}, _From, State) ->
    {reply,
     case dets:lookup(?CHORDDB, {Song#song.author, Song#song.title}) of
         [] -> undefined;
         [{_, Value} | _] -> {ok, Value}
     end,
     State};

handle_call(get_keys, _From, State) ->
    Keys = dets:traverse(?SONGDB, fun({Key, _}) -> {continue, Key} end),
    {reply, Keys, State}.

handle_cast(_, State) ->
    {noreply, State}.

handle_info(stop, State) ->
    {stop, shutdown, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% interface exports

save_text(Author, Title, Text) ->
    call({save_text, #song{author = toBinary(Author),
                           title = toBinary(Title),
                           text = toBinary(Text)}}).

delete_song(Author, Title) ->
    call({delete_song, #song{author = toBinary(Author),
                             title = toBinary(Title)}}).

get_text(Author, Title) ->
    case call({get_text, #song{author = toBinary(Author),
                               title = toBinary(Title)}}) of
        {ok, Song} when is_record(Song, song) -> Song#song.text;
        {error, not_found} ->
            io_lib:format("Sorry, no ~w - ~w song was found", [Author, Title])
    end.

save_chords(Author, Title, Chords) ->
    call({save_chords, #song{author = toBinary(Author),
                             title = toBinary(Title),
                             chords = Chords}}).

get_chords(Author, Title) ->
    case call({get_chords, #song{author = toBinary(Author),
                                 title = toBinary(Title)}}) of
        {ok, Chords} -> Chords;
        undefined -> undefined
    end.

get_keys() ->
    call(get_keys).

%% helpers

call(Request) ->
    gen_server:call(?MODULE, Request).

toBinary(undefined) ->
    unknown;
toBinary(unknown) ->
    unknown;
toBinary("") ->
    unknown;
toBinary(<<>>) ->
    unknown;
toBinary("unknown") ->
    unknown;
toBinary(Value) when is_list(Value) ->
    try
        list_to_binary(Value)
    catch
        _ -> unicode:characters_to_binary(Value)
    end;
toBinary(Value) when is_binary(Value) ->
    Value.

