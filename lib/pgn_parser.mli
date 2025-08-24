(** PGN (Portable Game Notation) parser for chess games *)

type piece = 
  | King
  | Queen 
  | Rook
  | Bishop
  | Knight
  | Pawn

type square = char * int

type board = (piece option * bool) array array

type zobrist_hash = int64

type move_type =
  | Normal of piece * square * square
  | Capture of piece * square * square * piece option
  | Castle of bool
  | EnPassant of square * square
  | Promotion of square * square * piece
  | Check
  | Checkmate
  | Draw

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

type game_result =
  | WhiteWin
  | BlackWin
  | Draw
  | Ongoing

type player = {
  name: string;
  elo: int option;
  title: string option;
}

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

type game = {
  info: game_info;
  moves: move list;
  final_position: string option;
}

type parse_error =
  | InvalidMove of string
  | InvalidTag of string
  | InvalidFormat of string
  | UnexpectedEnd of string

type 'a parse_result = ('a, parse_error) Stdlib.result

type pgn_document = game list

val parse_game : string -> game parse_result

val parse_document : string -> pgn_document parse_result

val to_pgn : game -> string

val document_to_pgn : pgn_document -> string

val pp_game : Format.formatter -> game -> unit

val pp_error : Format.formatter -> parse_error -> unit

val format_move_type : ?check:bool -> ?mate:bool -> move_type -> string

val parse_simple_move : string -> move_type parse_result

val create_starting_position : unit -> board
val create_empty_board : unit -> board
val square_to_indices : square -> int * int
val indices_to_square : int * int -> square

val calculate_zobrist_hash : board -> zobrist_hash
val apply_move_to_board : board -> move_type -> bool -> board

val positions_equal : board -> board -> bool
val zobrist_equal : zobrist_hash -> zobrist_hash -> bool

val board_to_string : board -> string
val print_board : board -> unit
val get_board_after_move : move list -> int -> bool -> board option
val get_final_board : move list -> board option
val visualize_game_progression : game -> string
