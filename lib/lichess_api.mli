(** Lichess API client for fetching random games *)

(** Game information from Lichess API *)
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

(** Player information from Lichess API *)
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

(** Tournament information from Lichess API *)
type lichess_tournament = {
  id: string;
  name: string;
  status: string;
  start_date: int64;
  end_date: int64 option;
  nb_players: int;
  time_control: string;
  variant: string;
  rated: bool;
}

(** Player statistics from Lichess API *)
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

(** Fetch a random game from Lichess *)
val fetch_random_game : unit -> lichess_game option Lwt.t

(** Fetch multiple random games *)
val fetch_random_games : int -> lichess_game list Lwt.t

(** Convert Lichess game to PGN format *)
val lichess_game_to_pgn : lichess_game -> string

(** Fetch player information from Lichess API *)
val fetch_player_info : string -> lichess_player option Lwt.t

(** Fetch games by player username *)
val fetch_player_games : string -> ?max_games:int -> ?_since:int64 option -> ?_until:int64 option -> unit -> lichess_game list Lwt.t

(** Fetch game by game ID *)
val fetch_game_by_id : string -> lichess_game option Lwt.t

(** Fetch ongoing games *)
val fetch_ongoing_games : unit -> lichess_game list Lwt.t

(** Search games with filters *)
val search_games : ?player:string option -> ?variant:string option -> ?speed:string option -> ?_rated:bool option -> ?max_games:int -> unit -> lichess_game list Lwt.t

(** Get player statistics *)
val get_player_stats : string -> player_stats option Lwt.t





(** Print player statistics *)
val print_player_stats : player_stats -> unit
