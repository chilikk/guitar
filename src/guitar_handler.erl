-module(guitar_handler).
-behaviour(cowboy_handler).

-export([init/2]).
-export([terminate/3]).

init(#{path := <<"/">>, method := <<"GET">>} = Req0, State) ->
    ToggleChords = toggle_chords(),
    SongList = guitar_song:html_list(song_list_entry_template()),
    Song = song_text(Req0),
    Req = cowboy_req:reply(
            200, #{<<"content-type">> => <<"text/html; charset=utf-8">>},
            io_lib:format(view_template(), [ToggleChords, SongList, Song]),
            Req0),
    {ok, Req, State};
init(#{path := <<"/song">>, method := <<"GET">>} = Req0, State) ->
    Req = cowboy_req:reply(
            200, #{<<"content-type">> => <<"text/html; charset=utf-8">>},
            song_text(Req0), Req0),
    {ok, Req, State};
init(#{path := <<"/admin">>, method := <<"GET">>} = Req0, State) ->
    EditList = guitar_song:html_list(admin_song_list_entry_template()),
    Edit = edit_text(Req0),
    Req = cowboy_req:reply(
            200, #{<<"content-type">> => <<"text/html; charset=utf-8">>},
            io_lib:format(admin_template(), [EditList, Edit]),
            Req0),
    {ok, Req, State};
init(#{path := <<"/admin/edit">>, method := <<"GET">>} = Req0, State) ->
    Req = cowboy_req:reply(
            200, #{<<"content-type">> => <<"text/html; charset=utf-8">>},
            edit_text(Req0), Req0),
   {ok, Req, State};
init(#{path := <<"/admin/op">>, method := <<"POST">>} = Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_urlencoded_body(Req0),
    Result = case {lists:keyfind(<<"op">>, 1, Body),
                   lists:keyfind(<<"a">>, 1, Body),
                   lists:keyfind(<<"t">>, 1, Body),
                   lists:keyfind(<<"x">>, 1, Body)} of
                 {{_, <<"delete">>}, {_, Author}, {_, Title}, _Text} ->
                     delete_song(Author, Title);
                 {{_, <<"delete">>}, false, {_, Title}, _Text} ->
                     delete_song(undefined, Title);
                 {{_, <<"save">>}, {_, Author}, {_, Title}, {_, Text}} ->
                     save_song(Author, Title, Text);
                 {{_, <<"save">>}, false, {_, Title}, {_, Text}} ->
                     save_song(unknown, Title, Text);
                 _ ->
                     <<"invalid operation">>
             end,
    Resp = case Result of
               {ok, Info, AdditionalInfo} ->
                   io_lib:format(operation_ok_template(),
                                 [Info, AdditionalInfo]);
               {error, Info, Reason} ->
                   io_lib:format(operation_err_template(),
                                 [Info, Reason])
           end,
    Req = cowboy_req:reply(
            200, #{<<"content-type">> => <<"text/html; charset=utf-8">>},
            Resp, Req1),
    {ok, Req, State}.

terminate(_Reason, _Req, _State) ->
    ok.

view_template() ->
    html(<<(head())/binary,
           (body(<<(header())/binary,
                   (main_part())/binary,
                   (footer())/binary>>
                ))/binary>>).

admin_template() ->
    html(<<(admin_head())/binary,
           (body(<<(admin_header())/binary,
                   (main_part())/binary,
                   (footer())/binary>>
                ))/binary>>).

html(Binary) ->
    <<"<!DOCTYPE html><html>", Binary/binary, "</html>">>.

head() ->
    head(<<"">>).

admin_head() ->
    Admin = <<"<link rel='stylesheet' type='text/css' "
              "href='../css/admin-style.css' />\n  "
              "<script type='text/javascript' src='../js/admin.js'>"
              "</script>\n">>,
    head(Admin).

head(Extra) ->
    <<"<head>
  <title>Denys' song database</title>
  <meta name='viewport' content='width=device-width, initial-scale=1.0'>
  <link rel='stylesheet' type='text/css' href='css/bootstrap.min.css' />
  <link rel='stylesheet' type='text/css' href='css/bootstrap-theme.min.css' />
  <link rel='stylesheet' type='text/css' href='css/style.css' />
  <script type='text/javascript' src='js/jquery-1.10.2.js'></script>
  <script type='text/javascript' src='js/bootstrap.min.js'></script>
  <script type='text/javascript' src='js/raphael.js'></script>
  <script type='text/javascript' src='js/jtab.js'></script>
  <script type='text/javascript' src='js/display.js'></script>
  ", Extra/binary, "</head>\n">>.

body(Body) ->
    <<"<body>
  <div id='outwrapper' class='container'>
  ", Body/binary, "</div></body>">>.

header() ->
    <<"<div class='navbar navbar-default'>
      <div class='container'>
        <a class='navbar-brand' href=''>Denys' song database</a>
        <div class='nav-collapse'>
          <ul class='nav navbar-nav pull-right'>
            <li id='showchordsbtn' style='display:none'>
              <a href='#' onclick='toggle_chords()'>~s</a>
            </li>
            <input id='openchords' type='hidden' value='0' />
            <input id='activesong' type='hidden' value='' />
          </ul>
        </div>
      </div>
    </div>">>.

admin_header() ->
    <<"<div class='navbar navbar-default'>
      <div class='container'>
        <a class='navbar-brand' href='..'>Denys' song database</a>
        <button type='button' class='btn btn-default pull-right' "
        "style='margin:7px' onclick='edit_song(\"\")'>Add a new song</button>
      </div>
    </div>">>.

main_part() ->
    <<"<div id='inwrapper'>
      <div id='list' class='col-lg-4 col-md-4 col-sm-4 col-xs-4 list-group'>
        <ul>
          ~s
        </ul>
      </div>
      <div id='content' class='col-lg-8 col-md-8 col-sm-8 col-xs-8'>
        ~s
      </div>
    </div>">>.

footer() ->
    <<"<div id='footer'>
      <div class='container'>
        <div class='text-muted credit'>
          Denys Knertser &middot; 2013..2021
        </div>
      </div>
    </div>">>.

toggle_chords() -> unicode:characters_to_binary("Показать аппликатуры").

song_list_entry_template() ->
    <<"<a class='list-group-item' href='#' "
      "onclick='load_song(\"~s\")'>~s</a>">>.

admin_song_list_entry_template() ->
    <<"<a class='list-group-item' href='#' "
      "onclick='edit_song(\"~s\")'>~s</a>">>.

song_text(Req) ->
   QS = cowboy_req:parse_qs(Req),
   case {lists:keyfind(<<"a">>, 1, QS), lists:keyfind(<<"t">>, 1, QS)} of
     {{_, Author}, {_, Title}} ->
           {FullTitle, Text, ChordList} = guitar_song:show(Author, Title),
           Chords = case ChordList of
                        [] ->
                            "";
                        _ ->
                            io_lib:format("<div id='chords'>~s</div>",
                                          [format_chords(ChordList)])
                    end,
           io_lib:format(song_template(), [FullTitle, Chords, Text]);
       _ ->
           ""
   end.

edit_text(Req) ->
   QS = cowboy_req:parse_qs(Req),
   {DisplayAuthor, DisplayTitle, DisplayText} =
       case {lists:keyfind(<<"a">>, 1, QS), lists:keyfind(<<"t">>, 1, QS)} of
           {{_, Author}, {_, Title}} ->
               Text = guitar_song:get_text(Author, Title),
               {Author, Title, Text};
           {false, {_, Title}} ->
               Text = guitar_song:get_text(undefined, Title),
               {"", Title, Text};
           _ -> {"Author", "Title", "Text"}
       end,
   io_lib:format(edit_template(), [DisplayAuthor, DisplayTitle, DisplayText]).

edit_template() ->
    <<(edit_controls())/binary,
        "<div id='opresult' class='clearfix'></div>"
        "<div id='text' class='clearfix'>"
        "<h3 type=text id='editauthor' contentEditable>~s</h3>"
        "<h3 id='editdivider'>&nbsp;::&nbsp;</h3>"
        "<h3 type=text id='edittitle' contentEditable>~s</h3>"
        "<br />"
        "<textarea id='edittext'>~s</textarea>"
        "</div>",
        (edit_controls())/binary>>.

edit_controls() ->
    <<"<div class='controls clearfix'>"
      "<button class='btn btn-primary' type=button "
          "onclick='save_song()'>save</button>&nbsp;"
      "<button class='btn btn-danger' type=button "
          "onclick='delete_song()'>delete</button>"
      "</div>">>.

format_chords(ChordList) ->
  format_chords(ChordList, "").

format_chords([], Result) ->
  Result;
format_chords([Chord | ChordList], Result) ->
  format_chords(ChordList,
                io_lib:format("~s<div class='jtab chordonly'>~s</div>",
                              [Result, unicode:characters_to_binary(Chord)])).

song_template() ->
    <<"<button class='btn btn-default' id='editbtn' "
              "onclick='window.location=\"admin\"'"
      ">edit song</button>"
      "<h3>~s</h3>"
      "~s<pre>~s</pre>">>.

delete_song(Author, Title) ->
    Info = io_lib:format("Deleting '~s'...",
                         [guitar_song:get_title(Author, Title)]),
    case guitar_song:delete(Author, Title) of
        ok ->
            {ok, Info, <<>>};
        {error, Reason} ->
            {error, Info, io_lib:format("~p", [Reason])}
    end.

save_song(Author, Title, Text) ->
    Info = io_lib:format("Saving '~s'...",
                         [guitar_song:get_title(Author, Title)]),
    case guitar_song:save(Author, Title, Text) of
        ok ->
            {ok, Info, save_song_info()};
        {error, Reason} ->
            {error, Info, io_lib:format("~p", [Reason])}
    end.

save_song_info() ->
    <<"You might need to delete the original song if you changed"
      " the author / the title of the song.<br />">>.

operation_ok_template() ->
    <<"<div class='alert alert-success'>~s ok</div>"
      "<div class='alert alert-info'>~s"
      "<a href=''>Reload</a> the page to refresh list</div>">>.

operation_err_template() ->
    <<"<div class='alert alert-danger'>~s error: ~s</div>">>.
