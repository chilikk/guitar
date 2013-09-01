-module(songdets).

-export([open_wait/0, saveText/3, getText/2, saveChords/3, getChords/2, getKeys/0, deleteSong/2]).

-define(SONGDBFILE, "/srv/www/guitar/song.db").
-define(CHORDDBFILE, "/srv/www/guitar/chord.db").

db_up() ->
	case whereis(dbhost) of
		undefined -> spawn(songdets, open_wait, []), 
			wait_db_up();
		_ -> ok
	end.

wait_db_up() ->
	case whereis(dbhost) of
		undefined -> wait_db_up();
		_ -> ok
	end.

open_wait() ->
	open(),
	register(dbhost,self()),
	loop().

open() ->
	{ok, songdb} = dets:open_file(songdb, [{file, ?SONGDBFILE}]),
	{ok, chorddb} = dets:open_file(chorddb, [{file, ?CHORDDBFILE}]).

loop() ->
	receive
		quit -> ok;
		_Other -> loop()
	end.

toBinary(undefined) ->
	undefined;
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

saveText(Author, Title, Text) ->
	db_up(),
	dets:insert(songdb, { {toBinary(Author), toBinary(Title)}, toBinary(Text)}).

deleteSong(Author, Title) ->
	db_up(),
	dets:delete(songdb, {toBinary(Author), toBinary(Title)}).

getText(Author, Title) ->
	db_up(),
	Key = {toBinary(Author), toBinary(Title)},
	case dets:lookup(songdb, Key) of
		[{_, Value} | _] -> Value;
		_ -> io_lib:format("Sorry, no ~w song was found", [Key])
	end.

saveChords(Author, Title, Chords) -> % Chords is a list of "strings"
	db_up(),
	dets:insert(chorddb, {{toBinary(Author), toBinary(Title)}, Chords}).

getChords(Author, Title) ->
	db_up(),
	case dets:lookup(chorddb, {toBinary(Author), toBinary(Title)}) of
		[] -> undefined;
		[{_, Value} | _] -> Value
	end.

getKeys() ->
	db_up(),
	dets:traverse(songdb, fun({Key, _}) -> {continue, Key} end).
