-module(song).

-include("song.hrl").

-export([html_list/1, show/2, delete/2, save/3,
         get_text/2, get_link/2, get_title/2]).

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
        ?DB:get_keys()),
    html_list(List, Format, "").

html_list([{Author, Title} | List], Format, HtmlResult) ->
    HyperLink = get_link(Author, Title),
    FullTitle = get_title(Author, Title),
    NewResult = string:concat(
                    io_lib:format(Format, [HyperLink, FullTitle]),
                    HtmlResult
                ),
    html_list(List, Format, NewResult);

html_list([], _, HtmlResult) ->
    HtmlResult.

get_link(Author, Title) ->
    yaws_api:f("?a=~s&t=~s", [escape(Author), escape(Title)]).

escape(Text) ->
    yaws_api:url_encode(lists:flatten(yaws_api:f("~s", [Text]))).

get_title(Author, Title) ->
    case {Author, Title} of
        {unknown, unknown} -> "";
        {unknown, _} -> io_lib:format("~s", [Title]);
        {"unknown", _} -> io_lib:format("~s", [Title]);
        {_, _} -> io_lib:format("~s - ~s", [Author, Title])
    end.

get_text(Author, Title) ->
    ?DB:get_text(Author, Title).

show(Author, Title) ->
    Text = get_text(Author, Title),
    FullTitle = get_title(Author, Title),
    SongChords = fetch_chords(Text), % todo: fix to db
    {FullTitle, Text, SongChords}.

delete(Author, Title) ->
    ?DB:delete_song(Author, Title).

save(Author, Title, Text) ->
    ?DB:save_song(Author, Title, Text).

fetch_chords(Text) ->
    ChordPattern = "[A-H][#b]?(?:maj7|m7b5|maj9|add9|sus2|sus4|dim7|7b5|7#5|"
                   "7b9|dim|aug|13|69|m7|m6|m9|m|6|7|9)?",
    {ok, ChordLinePattern} = re:compile(
            io_lib:format("^(?:<.*>|[ \|])*(?:~s[ \/\|]*)+$",[ChordPattern]),
            [multiline]),
    ChordLines =
        case re:run(Text, ChordLinePattern, [global, {capture,all,list}]) of
            {match, M1} -> M1;
            _ -> []
        end,
    ChordLinesJoin = [lists:flatten(string:join(ChordLines," "))],
    Chords =
        case re:run(ChordLinesJoin, ChordPattern, [global, {capture,all,list}]) of
            {match, M2} -> M2;
            _ -> []
        end,
    lists:usort(Chords).
