(** PGN (Portable Game Notation) parser for chess games 
    
    This module provides comprehensive parsing and manipulation of chess games
    in PGN format. It supports parsing complete games, individual moves,
    board visualization, and Zobrist hashing for position comparison.
*)

(** Chess piece types *)
type piece = 
  | King    (** King piece *)
  | Queen   (** Queen piece *)
  | Rook    (** Rook piece *)
  | Bishop  (** Bishop piece *)
  | Knight  (** Knight piece *)
  | Pawn    (** Pawn piece *)

(** Chess square represented as (file, rank) where file is 'a'-'h' and rank is 1-8 *)
type square = char * int

(** Chess board represented as 8x8 array where each cell contains (piece option, is_white) *)
type board = (piece option * bool) array array

(** Zobrist hash for efficient position comparison and repetition detection *)
type zobrist_hash = int64

(** Types of chess moves *)
type move_type =
  | Normal of piece * square * square        (** Normal move: piece from square to square *)
  | Capture of piece * square * square * piece option  (** Capture move with captured piece *)
  | Castle of bool                           (** Castling: true for kingside, false for queenside *)
  | EnPassant of square * square             (** En passant capture *)
  | Promotion of square * square * piece     (** Pawn promotion *)
  | Check                                    (** Check annotation *)
  | Checkmate                                (** Checkmate annotation *)
  | Draw                                     (** Draw annotation *)

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

(** Parse a single PGN game from string *)
val parse_game : string -> game parse_result

(** Parse multiple PGN games from string *)
val parse_document : string -> pgn_document parse_result

(** Convert a game back to PGN string format *)
val to_pgn : game -> string

(** Convert multiple games back to PGN string format *)
val document_to_pgn : pgn_document -> string

(** Pretty-print a game using Format module *)
val pp_game : Format.formatter -> game -> unit

(** Pretty-print a parse error using Format module *)
val pp_error : Format.formatter -> parse_error -> unit

(** Format a move type as string with optional check/mate annotations *)
val format_move_type : ?check:bool -> ?mate:bool -> move_type -> string

(** Parse a simple move string (e.g., "e4", "Nf3", "O-O") *)
val parse_simple_move : string -> move_type parse_result

(** Create a board with pieces in starting position *)
val create_starting_position : unit -> board

(** Create an empty board with no pieces *)
val create_empty_board : unit -> board

(** Convert chess square to array indices *)
val square_to_indices : square -> int * int

(** Convert array indices to chess square *)
val indices_to_square : int * int -> square

(** Calculate Zobrist hash for a board position *)
val calculate_zobrist_hash : board -> zobrist_hash

(** Apply a move to a board, returning the new board position *)
val apply_move_to_board : board -> move_type -> bool -> board

(** Compare two board positions for equality *)
val positions_equal : board -> board -> bool

(** Compare two Zobrist hashes for equality *)
val zobrist_equal : zobrist_hash -> zobrist_hash -> bool

(** Convert board to string representation *)
val board_to_string : board -> string

(** Print board to stdout *)
val print_board : board -> unit

(** Get board position after a specific move number *)
val get_board_after_move : move list -> int -> bool -> board option

(** Get the final board position from a list of moves *)
val get_final_board : move list -> board option

(** Create a string showing the progression of a game *)
val visualize_game_progression : game -> string
