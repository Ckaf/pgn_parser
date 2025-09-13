---
layout: default
title: API Reference
description: Complete API reference for PGN Parser, Lichess API, and Chess.com API modules
---

# API Reference

## Pgn_parser Module

Main module for parsing and working with PGN files.

### Types

#### `piece`
```ocaml
type piece = 
  | King    (** King piece *)
  | Queen   (** Queen piece *)
  | Rook    (** Rook piece *)
  | Bishop  (** Bishop piece *)
  | Knight  (** Knight piece *)
  | Pawn    (** Pawn piece *)
```

#### `square`
```ocaml
type square = char * int
```
Represents a chess square as (file, rank) where file is 'a'-'h' and rank is 1-8.

#### `board`
```ocaml
type board = (piece option * bool) array array
```
Chess board represented as 8x8 array where each cell contains (piece option, is_white).

#### `zobrist_hash`
```ocaml
type zobrist_hash = int64
```
Zobrist hash for efficient position comparison and repetition detection.

#### `move_type`
```ocaml
type move_type =
  | Normal of piece * square * square        (** Normal move: piece from square to square *)
  | Capture of piece * square * square * piece option  (** Capture move with captured piece *)
  | Castle of bool                           (** Castling: true for kingside, false for queenside *)
  | EnPassant of square * square             (** En passant capture *)
  | Promotion of square * square * piece     (** Pawn promotion *)
  | Check                                    (** Check annotation *)
  | Checkmate                                (** Checkmate annotation *)
  | Draw                                     (** Draw annotation *)
```

#### `move`
```ocaml
type move = {
  number: int;
  white_move: move_type option;
  black_move: move_type option;
  white_check: bool;
  white_mate: bool;
  black_check: bool;
  black_mate: bool;
  annotations: string list;
  position_after_white: board option;
  position_after_black: board option;
  zobrist_after_white: zobrist_hash option;
  zobrist_after_black: zobrist_hash option;
}
```

#### `game_result`
```ocaml
type game_result =
  | WhiteWin
  | BlackWin
  | Draw
  | Ongoing
```

#### `player`
```ocaml
type player = {
  name: string;
  elo: int option;
  title: string option;
}
```

#### `game_info`
```ocaml
type game_info = {
  event: string option;
  site: string option;
  date: string option;
  round: string option;
  white: player option;
  black: player option;
  result: game_result option;
  white_elo: int option;
  black_elo: int option;
  eco: string option;
  opening: string option;
  variation: string option;
  time_control: string option;
  termination: string option;
  annotator: string option;
  ply_count: int option;
}
```

#### `game`
```ocaml
type game = {
  info: game_info;
  moves: move list;
  final_position: string option;
}
```

#### `parse_error`
```ocaml
type parse_error =
  | InvalidMove of string
  | InvalidTag of string
  | InvalidFormat of string
  | UnexpectedEnd of string
```

### Functions

#### Parsing Functions

##### `parse_game`
```ocaml
val parse_game : string -> game parse_result
```
Parses a single PGN game from a string.

**Example:**
```ocaml
let pgn = "[Event \"Test\"]\n[White \"Alice\"]\n[Black \"Bob\"]\n\n1. e4 e5 2. Nf3" in
match parse_game pgn with
| Ok game -> Printf.printf "Parsed %d moves\n" (List.length game.moves)
| Error e -> Printf.printf "Parse error\n"
```

##### `parse_document`
```ocaml
val parse_document : string -> pgn_document parse_result
```
Parses multiple PGN games from a string.

##### `parse_simple_move`
```ocaml
val parse_simple_move : string -> move_type parse_result
```
Parses a simple move string (e.g., "e4", "Nf3", "O-O").

**Example:**
```ocaml
match parse_simple_move "e4" with
| Ok (Normal (Pawn, ('e', 2), ('e', 4))) -> Printf.printf "Valid pawn move\n"
| Error _ -> Printf.printf "Invalid move\n"
```

#### Conversion Functions

##### `to_pgn`
```ocaml
val to_pgn : game -> string
```
Converts a game back to PGN string format.

##### `document_to_pgn`
```ocaml
val document_to_pgn : pgn_document -> string
```
Converts multiple games back to PGN string format.

#### Board Functions

##### `create_starting_position`
```ocaml
val create_starting_position : unit -> board
```
Creates a board with pieces in starting position.

##### `create_empty_board`
```ocaml
val create_empty_board : unit -> board
```
Creates an empty board with no pieces.

##### `apply_move_to_board`
```ocaml
val apply_move_to_board : board -> move_type -> bool -> board
```
Applies a move to a board, returning the new board position.

**Parameters:**
- `board`: current board position
- `move_type`: move to apply
- `bool`: true for white, false for black

##### `positions_equal`
```ocaml
val positions_equal : board -> board -> bool
```
Compares two board positions for equality.

#### Zobrist Hashing

##### `calculate_zobrist_hash`
```ocaml
val calculate_zobrist_hash : board -> zobrist_hash
```
Calculates Zobrist hash for a board position.

##### `zobrist_equal`
```ocaml
val zobrist_equal : zobrist_hash -> zobrist_hash -> bool
```
Compares two Zobrist hashes for equality.

#### Utility Functions

##### `square_to_indices`
```ocaml
val square_to_indices : square -> int * int
```
Converts chess square to array indices.

##### `indices_to_square`
```ocaml
val indices_to_square : int * int -> square
```
Converts array indices to chess square.

#### Visualization Functions

##### `board_to_string`
```ocaml
val board_to_string : board -> string
```
Converts board to string representation.

##### `print_board`
```ocaml
val print_board : board -> unit
```
Prints board to stdout.

##### `visualize_game_progression`
```ocaml
val visualize_game_progression : game -> string
```
Creates a string showing the progression of a game.

##### `get_board_after_move`
```ocaml
val get_board_after_move : move list -> int -> bool -> board option
```
Gets board position after a specific move number.

##### `get_final_board`
```ocaml
val get_final_board : move list -> board option
```
Gets the final board position from a list of moves.

#### Formatting Functions

##### `format_move_type`
```ocaml
val format_move_type : ?check:bool -> ?mate:bool -> move_type -> string
```
Formats a move type as string with optional check/mate annotations.

##### `pp_game`
```ocaml
val pp_game : Format.formatter -> game -> unit
```
Pretty-prints a game using Format module.

##### `pp_error`
```ocaml
val pp_error : Format.formatter -> parse_error -> unit
```
Pretty-prints a parse error using Format module.

## Lichess_api Module

Client for Lichess API for fetching random games.

### Types

#### `lichess_game`
```ocaml
type lichess_game = {
  id: string;
  white: string;
  black: string;
  pgn: string;
  winner: string option;
  speed: string;
  status: string;
  created_at: int64;
  rating_white: int option;
  rating_black: int option;
  time_control: string option;
  variant: string option;
  opening: string option;
}
```

#### `lichess_player`
```ocaml
type lichess_player = {
  id: string;
  username: string;
  rating: int option;
  title: string option;
  online: bool;
  playing: bool;
  country: string option;
  created_at: int64;
}
```

#### `player_stats`
```ocaml
type player_stats = {
  total_games: int;
  wins: int;
  losses: int;
  draws: int;
  win_rate: float;
  rating_avg: int;
  best_rating: int;
  current_rating: int;
}
```

### Functions

#### `fetch_random_game`
```ocaml
val fetch_random_game : unit -> lichess_game option Lwt.t
```
Fetches a random game from Lichess.

#### `fetch_random_games`
```ocaml
val fetch_random_games : int -> lichess_game list Lwt.t
```
Fetches multiple random games from Lichess.

#### `fetch_player_info`
```ocaml
val fetch_player_info : string -> lichess_player option Lwt.t
```
Fetches player information by username.

#### `fetch_player_games`
```ocaml
val fetch_player_games : string -> ?max_games:int -> ?_since:int64 option -> ?_until:int64 option -> unit -> lichess_game list Lwt.t
```
Fetches player games by username.

#### `get_player_stats`
```ocaml
val get_player_stats : string -> player_stats option Lwt.t
```
Gets player statistics.

## Chess_com_api Module

Client for Chess.com API for fetching games and player information.

### Types

#### `chess_com_game`
```ocaml
type chess_com_game = {
  id: string;
  white: string;
  black: string;
  pgn: string;
  winner: string option;
  speed: string;
  game_state: string;
  created_at: int64;
  rating_white: int option;
  rating_black: int option;
  time_control: string option;
  variant: string option;
  opening: string option;
  end_time: int64 option;
  time_class: string option;
  rules: string option;
  tournament: string option;
}
```

#### `chess_com_player`
```ocaml
type chess_com_player = {
  id: string;
  username: string;
  rating: int option;
  title: string option;
  online: bool;
  playing: bool;
  country: string option;
  created_at: int64;
  followers: int option;
  following: int option;
  is_streamer: bool;
  is_verified: bool;
  is_online: bool;
}
```

### Functions

#### `fetch_random_game`
```ocaml
val fetch_random_game : unit -> chess_com_game option Lwt.t
```
Fetches a random game from Chess.com.

#### `fetch_player_games`
```ocaml
val fetch_player_games : string -> ?max_games:int -> ?_since:'a option -> ?_until:'b option -> unit -> chess_com_game list Lwt.t
```
Fetches player games from Chess.com.

#### `get_daily_puzzle`
```ocaml
val get_daily_puzzle : unit -> chess_com_puzzle option Lwt.t
```
Gets daily puzzle from Chess.com.

## Error Handling

All parsing functions return `parse_result`, which can be:
- `Ok value` - successful result
- `Error parse_error` - parsing error

### Types of Errors

- `InvalidMove of string` - invalid move
- `InvalidTag of string` - invalid tag
- `InvalidFormat of string` - invalid format
- `UnexpectedEnd of string` - unexpected end

### Example Error Handling

```ocaml
match parse_game pgn_string with
| Ok game -> 
    (* Handle successful parsing *)
    process_game game
| Error (InvalidMove move) -> 
    Printf.printf "Invalid move: %s\n" move
| Error (InvalidTag tag) -> 
    Printf.printf "Invalid tag: %s\n" tag
| Error (InvalidFormat format) -> 
    Printf.printf "Invalid format: %s\n" format
| Error (UnexpectedEnd reason) -> 
    Printf.printf "Unexpected end: %s\n" reason
```