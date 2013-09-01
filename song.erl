-module(song).

-export([html_list/1, show/2, getText/2, getLink/2, getTitle/2]).

html_list(Format) ->
	List = lists:sort(
		fun({A1,T1}, {A2,T2}) -> 
			case {A1, A2} of
				{unknown, _} -> true;
				{_, unknown} -> false;
				{A, A} -> T1>=T2;
				{_, _} -> A1>=A2
			end
		end, 
		songdets:getKeys()),
	html_list(List, Format, "").

html_list([ { Author, Title } | List ], Format, HtmlResult) ->
	HyperLink = getLink(Author, Title),
	FullTitle = getTitle(Author, Title),
	NewResult = string:concat(io_lib:format(Format, [HyperLink, FullTitle]), HtmlResult),
	html_list(List, Format, NewResult);

html_list([], _, HtmlResult) ->
	HtmlResult.

getLink(Author, Title) ->
	EscapedAuthor = yaws_api:url_encode(lists:flatten(yaws_api:f("~s", [Author]))),
	EscapedTitle = yaws_api:url_encode(lists:flatten(yaws_api:f("~s", [Title]))),
	yaws_api:f("?a=~s&t=~s", [EscapedAuthor, EscapedTitle]).

getTitle(Author, Title) ->
	case {Author, Title} of
		{unknown, unknown} -> "";
		{unknown, _} -> io_lib:format("~s", [Title]);
		{"unknown", _} -> io_lib:format("~s", [Title]);
		{_, _} -> io_lib:format("~s - ~s", [Author, Title])
	end.

getText(Author, Title) ->
	songdets:getText(Author, Title).

show(Author, Title) ->
	Text = getText(Author, Title),
	FullTitle = getTitle(Author, Title),
	SongChords = fetchChords(Text), % todo: fix to db
	{FullTitle, Text, SongChords}.
	

fetchChords(Text) ->
	ChordPattern = "[A-H][#b]?(?:maj7|m7b5|maj9|add9|sus2|sus4|dim7|7b5|7#5|7b9|dim|aug|13|69|m7|m6|m9|m|6|7|9)?",
	{ok, ChordLinePattern} = re:compile(io_lib:format("^(?:<.*>|[ \|])*(?:~s[ \/\|]*)+$",[ChordPattern]), [multiline]),
	ChordLines = case re:run(Text, ChordLinePattern, [global, {capture,all,list}]) of
		{match, M1} -> M1;
		_ -> []
	end,
	ChordLinesJoin = [lists:flatten(string:join(ChordLines," "))],
	Chords = case re:run(ChordLinesJoin, ChordPattern, [global, {capture,all,list}]) of
		{match, M2} -> M2;
		_ -> []
	end,
	lists:usort(Chords).
