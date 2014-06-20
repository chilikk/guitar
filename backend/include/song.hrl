-define(DB, db).
-define(SONGDB, songdb).
-define(CHORDDB, chorddb).

-record(song, {author :: binary(),
               title  :: binary(),
               text   :: binary(),
               chords :: [string()]
              }).
