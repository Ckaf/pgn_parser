(** Chess.com API client for fetching games and player information *)

(** Game information from Chess.com API *)
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

(** Player information from Chess.com API *)
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

(** Player statistics from Chess.com API *)
type chess_com_player_stats = {
  total_games: int;
  wins: int;
  losses: int;
  draws: int;
  win_rate: float;
  rating_avg: int;
  best_rating: int;
  current_rating: int;
  rapid_games: int;
  blitz_games: int;
  bullet_games: int;
  rapid_rating: int option;
  blitz_rating: int option;
  bullet_rating: int option;
}

(** Tournament information from Chess.com API *)
type chess_com_tournament = {
  id: string;
  name: string;
  status: string;
  start_date: int64;
  end_date: int64 option;
  nb_players: int;
  time_control: string;
  variant: string;
  rated: bool;
  prize_pool: string option;
  country: string option;
}

(** Fetch a random game from Chess.com *)
val fetch_random_game : unit -> chess_com_game option Lwt.t

(** Fetch multiple random games *)
val fetch_random_games : int -> chess_com_game list Lwt.t

(** Convert Chess.com game to PGN format *)
val chess_com_game_to_pgn : chess_com_game -> string

(** Fetch player information from Chess.com API *)
val fetch_player_info : string -> chess_com_player option Lwt.t

(** Fetch games by player username *)
val fetch_player_games : string -> ?max_games:int -> ?_since:'a option -> ?_until:'b option -> unit -> chess_com_game list Lwt.t

(** Fetch game by game ID *)
val fetch_game_by_id : string -> chess_com_game option Lwt.t

(** Fetch ongoing games *)
val fetch_ongoing_games : unit -> chess_com_game list Lwt.t

(** Search games with filters *)
val search_games : ?rated_match:bool option -> unit -> chess_com_game list Lwt.t

(** Get player statistics *)
val get_player_stats : string -> chess_com_player_stats option Lwt.t

(** Get player's monthly archives *)
val get_player_archives : string -> string list Lwt.t

(** Get games from specific archive *)
val get_games_from_archive : string -> chess_com_game list Lwt.t



(** Puzzle information from Chess.com API *)
type chess_com_puzzle = {
  title: string;
  fen: string;
  solution: string list;
}

(** Get daily puzzle *)
val get_daily_puzzle : unit -> chess_com_puzzle option Lwt.t

(** Get leaderboards *)
val get_leaderboards : unit -> (string * (string * int) list) list Lwt.t
