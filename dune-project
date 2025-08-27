(lang dune 3.19)

(name pgn_parser)
(version 1.0.0)

(generate_opam_files true)

(formatting (enabled_for ocaml))

(source
 (github ckaf/pgn_parser))

(authors "ckaf borisnovoselov602@gmail.com")

(maintainers "ckaf borisnovoselov602@gmail.com")

(license MIT)

(documentation https://github.com/ckaf/pgn_parser)

(homepage https://github.com/ckaf/pgn_parser)

(bug_reports https://github.com/ckaf/pgn_parser/issues)

(package
 (name pgn_parser)
 (synopsis "PGN (Portable Game Notation) parser for chess games")
 (description "A comprehensive PGN parser written in OCaml that supports parsing chess games from various sources including Lichess and Chess.com APIs. Features include board tracking, Zobrist hashing, property-based testing, and unfinished games support.")
 (depends
  (ocaml (>= 4.14))
  (dune (>= 3.0))
  (qcheck (>= 0.21))
  (cohttp-lwt-unix (>= 5.0))
  (yojson (>= 1.7))
  (lwt (>= 5.6))
  (lwt_ppx (>= 2.0)))
 (tags
  ("chess" "pgn" "parser" "lichess" "chess.com" "api" "testing" "zobrist" "board-tracking" "unfinished-games")))

(package
 (name lichess_api)
 (synopsis "Lichess API client for chess games")
 (description "A client library for the Lichess API that provides easy access to chess games, player data, and tournament information. Supports fetching games in PGN format and extracting metadata.")
 (depends
  (ocaml (>= 4.14))
  (dune (>= 3.0))
  (cohttp-lwt-unix (>= 5.0))
  (yojson (>= 1.7))
  (lwt (>= 5.6))
  (lwt_ppx (>= 2.0)))
 (tags
  ("chess" "lichess" "api" "http" "client" "games" "pgn"))
 (allow_empty))

(package
 (name chess_com_api)
 (synopsis "Chess.com API client for chess games")
 (description "A client library for the Chess.com API that provides easy access to chess games, player data, tournament information, and daily puzzles. Supports fetching games in PGN format and extracting metadata.")
 (depends
  (ocaml (>= 4.14))
  (dune (>= 3.0))
  (cohttp-lwt-unix (>= 5.0))
  (yojson (>= 1.7))
  (lwt (>= 5.6))
  (lwt_ppx (>= 2.0)))
 (tags
  ("chess" "chess.com" "api" "http" "client" "games" "pgn"))
 (allow_empty))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
