{application, backend,
  [{description,  "Song backend"},
   {vsn,          "1.0"},
   {modules, ['db_sup', 'song', 'db', 'backend']},
   {registered,   [db, db_sup]},
   {applications, [kernel, stdlib]},
   {mod,          {backend, []}}
  ]}.
