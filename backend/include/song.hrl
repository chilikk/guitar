-define(DB, db).
-define(SONGDB, songdb).
-define(SONGDBFILE, "../priv/song.db").
-define(CHORDDB, chorddb).
-define(CHORDDBFILE, "../priv/chord.db").

-record(song, {author :: binary(),
               title  :: binary(),
               text   :: binary(),
               chords :: [string()]
              }).
