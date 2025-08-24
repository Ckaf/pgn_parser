(** Chess.com API client for fetching games and player information *)

open Lwt.Syntax

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

(** Rating and date information *)
type rating_info = {
  rating: int;
  date: int;
}

(** Record information *)
type record_info = {
  win: int;
  loss: int;
  draw: int;
}

(** Daily chess statistics *)
type daily_stats = {
  last: rating_info;
  best: rating_info;
  record: record_info;
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

(** Puzzle information from Chess.com API *)
type chess_com_puzzle = {
  title: string;
  fen: string;
  solution: string list;
}

(* Удаляем неиспользуемые функции *)

(** Helper function to take first n elements from a list *)
let take n lst =
  let rec take_aux n lst acc =
    match lst, n with
    | _, 0 -> List.rev acc
    | [], _ -> List.rev acc
    | x :: xs, n -> take_aux (n-1) xs (x :: acc)
  in
  take_aux n lst []

(** Fetch games from a specific archive URL *)
let fetch_games_from_archive archive_url =
  let* response, body = Cohttp_lwt_unix.Client.get (Uri.of_string archive_url) in
  let* body_str = Cohttp_lwt.Body.to_string body in
  match Cohttp.Response.status response with
  | `OK ->
      try
        let json = Yojson.Basic.from_string body_str in
        match json with
        | `List games ->
            let parse_games (games : Yojson.Basic.t list) =
              List.fold_left (fun acc game ->
                match game with
                | `Assoc game_fields ->
                    let white = match List.assoc_opt "white" game_fields with
                      | Some (`String s) -> s
                      | _ -> "Unknown" in
                    let black = match List.assoc_opt "black" game_fields with
                      | Some (`String s) -> s
                      | _ -> "Unknown" in
                    let winner = match List.assoc_opt "winner" game_fields with
                      | Some (`String s) -> Some s
                      | _ -> None in
                    let pgn = match List.assoc_opt "pgn" game_fields with
                      | Some (`String s) -> s
                      | _ -> "" in
                    let time_control = match List.assoc_opt "time_control" game_fields with
                      | Some (`String s) -> Some s
                      | Some (`Int i) -> Some (string_of_int i)
                      | _ -> None in
                    let end_time = match List.assoc_opt "end_time" game_fields with
                      | Some (`Int i) -> Some (Int64.of_int i)
                      | _ -> None in
                    let speed = match List.assoc_opt "time_class" game_fields with
                      | Some (`String s) -> s
                      | _ -> "rapid" in
                    let game_state = match List.assoc_opt "status" game_fields with
                      | Some (`String s) -> s
                      | _ -> "finished" in
                    let created_at = match List.assoc_opt "created_at" game_fields with
                      | Some (`Int i) -> Int64.of_int i
                      | _ -> Int64.of_int (Unix.time () |> int_of_float) in
                    let rating_white = match List.assoc_opt "white_rating" game_fields with
                      | Some (`Int i) -> Some i
                      | _ -> None in
                    let rating_black = match List.assoc_opt "black_rating" game_fields with
                      | Some (`Int i) -> Some i
                      | _ -> None in
                    let variant = match List.assoc_opt "variant" game_fields with
                      | Some (`String s) -> Some s
                      | _ -> Some "standard" in
                    let opening = match List.assoc_opt "opening" game_fields with
                      | Some (`Assoc opening_fields) ->
                          (match List.assoc_opt "name" opening_fields with
                           | Some (`String s) -> Some s
                           | _ -> None)
                      | _ -> None in
                    let time_class = match List.assoc_opt "time_class" game_fields with
                      | Some (`String s) -> Some s
                      | _ -> None in
                    let rules = match List.assoc_opt "rules" game_fields with
                      | Some (`String s) -> Some s
                      | _ -> Some "chess" in
                    let tournament = match List.assoc_opt "tournament" game_fields with
                      | Some (`String s) -> Some s
                      | _ -> None in
                    let game = {
                      id = "unknown";
                      white;
                      black;
                      pgn;
                      winner;
                      speed;
                      game_state;
                      created_at;
                      rating_white;
                      rating_black;
                      time_control;
                      variant;
                      opening;
                      end_time;
                      time_class;
                      rules;
                      tournament
                    } in
                    game :: acc
                | _ -> acc
              ) [] games in
            let games = parse_games games in
            Lwt.return games
        | _ -> Lwt.return []
      with _ -> Lwt.return []
  | _ -> Lwt.return []

(** Convert Chess.com game to PGN format *)
let chess_com_game_to_pgn game =
  game.pgn

(** Fetch a random game from Chess.com *)
let fetch_random_game () =
  (* Get recent games from a popular player *)
  let url = "https://api.chess.com/pub/player/hikaru/games/2024/12" in

  let* (http_response, body) = Cohttp_lwt_unix.Client.get (Uri.of_string url) in
  let* body_str = Cohttp_lwt.Body.to_string body in

  match Cohttp.Response.status http_response with
  | `OK ->
      try
        let json = Yojson.Basic.from_string body_str in
        match json with
        | `Assoc fields ->
            let games = List.assoc "games" fields in
            (match games with
             | `List game_list ->
                 if List.length game_list > 0 then
                   let first_game = List.hd game_list in
                   (match first_game with
                    | `Assoc game_fields ->
                        let pgn = List.assoc "pgn" game_fields in
                                                 let _url = List.assoc "url" game_fields in
                        let time_control = List.assoc "time_control" game_fields in
                        let end_time = List.assoc "end_time" game_fields in
                        let time_class = List.assoc "time_class" game_fields in
                        let rules = List.assoc "rules" game_fields in
                        let white = List.assoc "white" game_fields in
                        let black = List.assoc "black" game_fields in
                        let uuid = List.assoc "uuid" game_fields in
                        
                        let white_username = match white with
                          | `Assoc w_fields -> 
                              (try match List.assoc "username" w_fields with `String s -> s | _ -> "Unknown"
                               with Not_found -> "Unknown")
                          | _ -> "Unknown" in
                        let black_username = match black with
                          | `Assoc b_fields -> 
                              (try match List.assoc "username" b_fields with `String s -> s | _ -> "Unknown"
                               with Not_found -> "Unknown")
                          | _ -> "Unknown" in
                        let white_rating = match white with
                          | `Assoc w_fields -> 
                              (try match List.assoc "rating" w_fields with `Int i -> Some i | _ -> None
                               with Not_found -> None)
                          | _ -> None in
                        let black_rating = match black with
                          | `Assoc b_fields -> 
                              (try match List.assoc "rating" b_fields with `Int i -> Some i | _ -> None
                               with Not_found -> None)
                          | _ -> None in
                        
                        let pgn_str = match pgn with
                          | `String s -> s
                          | _ -> "" in
                        
                        let game_id = match uuid with
                          | `String s -> s
                          | _ -> "unknown" in
                        
                        let speed_value = match time_class with `String s -> s | _ -> "unknown" in
                        let time_control_value = match time_control with `String s -> Some s | _ -> None in
                        let end_time_value = match end_time with `Int i -> Some (Int64.of_int i) | _ -> None in
                        let time_class_value = match time_class with `String s -> Some s | _ -> None in
                        let rules_value = match rules with `String s -> Some s | _ -> None in
                        let game_record : chess_com_game = {
                          id = game_id;
                          white = white_username;
                          black = black_username;
                          pgn = pgn_str;
                          winner = None; (* Would need to parse from PGN *)
                          speed = speed_value;
                          game_state = "finished";
                          created_at = Int64.of_int (Unix.time () |> int_of_float);
                          rating_white = white_rating;
                          rating_black = black_rating;
                          time_control = time_control_value;
                          variant = Some "standard";
                          opening = None; (* Would need to parse from PGN *)
                          end_time = end_time_value;
                          time_class = time_class_value;
                          rules = rules_value;
                          tournament = None;
                        } in
                        Lwt.return_some game_record
                    | _ -> Lwt.return_none)
                 else
                   Lwt.return_none
             | _ -> Lwt.return_none)
        | _ -> Lwt.return_none
      with _ -> Lwt.return_none
  | _ ->
      Lwt.return_none

(** Fetch multiple random games *)
let fetch_random_games count =
  let rec fetch_games acc remaining =
    if remaining <= 0 then
      Lwt.return acc
    else
      let* game_opt = fetch_random_game () in
      match game_opt with
      | Some game ->
          fetch_games (game :: acc) (remaining - 1)
      | None ->
          fetch_games acc (remaining - 1)
  in
  fetch_games [] count

(** Fetch player information from Chess.com API *)
let fetch_player_info username =
  let url = Printf.sprintf "https://api.chess.com/pub/player/%s" username in
  let* response, body = Cohttp_lwt_unix.Client.get (Uri.of_string url) in
  let* body_str = Cohttp_lwt.Body.to_string body in
  match Cohttp.Response.status response with
  | `OK ->
      try
        let json = Yojson.Basic.from_string body_str in
        match json with
        | `Assoc fields ->
            let username = match List.assoc_opt "username" fields with
              | Some (`String s) -> s
              | _ -> username in
            let _last_online = match List.assoc_opt "last_online" fields with
              | Some (`Int i) -> Some i
              | _ -> None in
            let player = {
              id = username;
              username;
              rating = None;
              title = None;
              online = false;
              playing = false;
              country = None;
              created_at = Int64.of_int 0;
              followers = None;
              following = None;
              is_streamer = false;
              is_verified = false;
              is_online = false
            } in
            Lwt.return (Some player)
        | _ -> Lwt.return_none
      with _ -> Lwt.return_none
  | _ -> Lwt.return_none

(** Get player's monthly archives *)
let get_player_archives username =
  let url = Printf.sprintf "https://api.chess.com/pub/player/%s/games/archives" username in
  let* response, body = Cohttp_lwt_unix.Client.get (Uri.of_string url) in
  let* _body_str = Cohttp_lwt.Body.to_string body in
  match Cohttp.Response.status response with
  | `OK ->
      try
        let json = Yojson.Basic.from_string _body_str in
        match json with
        | `Assoc fields ->
            let archives = match List.assoc_opt "archives" fields with
              | Some (`List archive_list) ->
                  List.fold_left (fun acc archive ->
                    match archive with
                    | `String s -> s :: acc
                    | _ -> acc
                  ) [] archive_list
              | _ -> [] in
            Lwt.return archives
        | _ -> Lwt.return []
      with _ -> Lwt.return []
  | _ -> Lwt.return []

(** Fetch games by player username *)
let fetch_player_games username ?(max_games=10) ?(_since=None) ?(_until=None) () =
  let* archives = get_player_archives username in
  let recent_archives = take 3 archives in
  let* all_games = Lwt_list.fold_left_s (fun acc archive ->
    let* games = fetch_games_from_archive archive in
    Lwt.return (List.append acc games)
  ) [] recent_archives in
  let limited_games = take max_games all_games in
  Lwt.return limited_games

(** Fetch game by game ID *)
let fetch_game_by_id game_id =
  let url = Printf.sprintf "https://api.chess.com/pub/game/%s" game_id in
  let* response, body = Cohttp_lwt_unix.Client.get (Uri.of_string url) in
  let* body_str = Cohttp_lwt.Body.to_string body in
  match Cohttp.Response.status response with
  | `OK ->
      try
        let json = Yojson.Basic.from_string body_str in
        match json with
        | `Assoc fields ->
            let white = match List.assoc_opt "white" fields with
              | Some (`String s) -> s
              | _ -> "Unknown" in
            let black = match List.assoc_opt "black" fields with
              | Some (`String s) -> s
              | _ -> "Unknown" in
            let winner = match List.assoc_opt "winner" fields with
              | Some (`String s) -> Some s
              | _ -> None in
            let pgn = match List.assoc_opt "pgn" fields with
              | Some (`String s) -> s
              | _ -> "" in
            let time_control = match List.assoc_opt "time_control" fields with
              | Some (`String s) -> Some s
              | Some (`Int i) -> Some (string_of_int i)
              | _ -> None in
            let end_time = match List.assoc_opt "end_time" fields with
              | Some (`Int i) -> Some (Int64.of_int i)
              | _ -> None in
            let speed = match List.assoc_opt "time_class" fields with
              | Some (`String s) -> s
              | _ -> "rapid" in
            let game_state = match List.assoc_opt "status" fields with
              | Some (`String s) -> s
              | _ -> "finished" in
            let created_at = match List.assoc_opt "created_at" fields with
              | Some (`Int i) -> Int64.of_int i
              | _ -> Int64.of_int (Unix.time () |> int_of_float) in
            let rating_white = match List.assoc_opt "white_rating" fields with
              | Some (`Int i) -> Some i
              | _ -> None in
            let rating_black = match List.assoc_opt "black_rating" fields with
              | Some (`Int i) -> Some i
              | _ -> None in
            let variant = match List.assoc_opt "variant" fields with
              | Some (`String s) -> Some s
              | _ -> Some "standard" in
            let _url = List.assoc "url" fields in
            let opening = match List.assoc_opt "opening" fields with
              | Some (`Assoc opening_fields) ->
                  (match List.assoc_opt "name" opening_fields with
                   | Some (`String s) -> Some s
                   | _ -> None)
              | _ -> None in
            let time_class = match List.assoc_opt "time_class" fields with
              | Some (`String s) -> Some s
              | _ -> None in
            let rules = match List.assoc_opt "rules" fields with
              | Some (`String s) -> Some s
              | _ -> Some "chess" in
            let tournament = match List.assoc_opt "tournament" fields with
              | Some (`String s) -> Some s
              | _ -> None in
            let game = {
              id = game_id;
              white;
              black;
              pgn;
              winner;
              speed;
              game_state;
              created_at;
              rating_white;
              rating_black;
              time_control;
              variant;
              opening;
              end_time;
              time_class;
              rules;
              tournament
            } in
            Lwt.return (Some game)
        | _ -> Lwt.return_none
      with _ -> Lwt.return_none
  | _ -> Lwt.return_none

(** Fetch ongoing games *)
let fetch_ongoing_games () =
  let url = "https://api.chess.com/pub/leaderboards" in
  let* response, body = Cohttp_lwt_unix.Client.get (Uri.of_string url) in
  let* body_str = Cohttp_lwt.Body.to_string body in
  match Cohttp.Response.status response with
  | `OK ->
      try
        let json = Yojson.Basic.from_string body_str in
        match json with
        | `Assoc fields ->
            let daily_players = match List.assoc_opt "daily" fields with
              | Some (`List players) ->
                  let parse_players players =
                    List.fold_left (fun acc player ->
                      match player with
                      | `Assoc player_fields ->
                          let username = match List.assoc_opt "username" player_fields with
                            | Some (`String s) -> s
                            | _ -> "Unknown" in
                          username :: acc
                      | _ -> acc
                    ) [] players in
                  parse_players players
              | _ -> [] in
            let top_players = take 5 daily_players in
            let* all_games = Lwt_list.fold_left_s (fun acc player ->
              let* games = fetch_player_games player ~max_games:5 () in
              Lwt.return (List.append acc games)
            ) [] top_players in
            let ongoing_games = List.filter (fun game ->
              game.game_state = "ongoing" || game.winner = None
            ) all_games in
            Lwt.return ongoing_games
        | _ -> Lwt.return []
      with _ -> Lwt.return []
  | _ -> Lwt.return []

(** Search games with filters *)
let search_games ?(rated_match=None) () =
  let url = "https://api.chess.com/pub/tournament/33rd-chesscom-qualifier-2024-11-20-2024-11-20" in
  let* response, body = Cohttp_lwt_unix.Client.get (Uri.of_string url) in
  let* body_str = Cohttp_lwt.Body.to_string body in
  match Cohttp.Response.status response with
  | `OK ->
      try
        let json = Yojson.Basic.from_string body_str in
        match json with
        | `Assoc fields ->
            let games = match List.assoc_opt "games" fields with
              | Some (`List game_list) ->
                  let parse_games (games : Yojson.Basic.t list) =
                    List.fold_left (fun acc game ->
                      match game with
                      | `Assoc game_fields ->
                          let white = match List.assoc_opt "white" game_fields with
                            | Some (`String s) -> s
                            | _ -> "Unknown" in
                          let black = match List.assoc_opt "black" game_fields with
                            | Some (`String s) -> s
                            | _ -> "Unknown" in
                          let winner = match List.assoc_opt "winner" game_fields with
                            | Some (`String s) -> Some s
                            | _ -> None in
                          let pgn = match List.assoc_opt "pgn" game_fields with
                            | Some (`String s) -> s
                            | _ -> "" in
                          let time_control = match List.assoc_opt "time_control" game_fields with
                            | Some (`String s) -> Some s
                            | Some (`Int i) -> Some (string_of_int i)
                            | _ -> None in
                          let end_time = match List.assoc_opt "end_time" game_fields with
                            | Some (`Int i) -> Some (Int64.of_int i)
                            | _ -> None in
                          let speed = match List.assoc_opt "time_class" game_fields with
                            | Some (`String s) -> s
                            | _ -> "rapid" in
                          let game_state = match List.assoc_opt "status" game_fields with
                            | Some (`String s) -> s
                            | _ -> "finished" in
                          let created_at = match List.assoc_opt "created_at" game_fields with
                            | Some (`Int i) -> Int64.of_int i
                            | _ -> Int64.of_int (Unix.time () |> int_of_float) in
                          let rating_white = match List.assoc_opt "white_rating" game_fields with
                            | Some (`Int i) -> Some i
                            | _ -> None in
                          let rating_black = match List.assoc_opt "black_rating" game_fields with
                            | Some (`Int i) -> Some i
                            | _ -> None in
                          let variant = match List.assoc_opt "variant" game_fields with
                            | Some (`String s) -> Some s
                            | _ -> Some "standard" in
                          let opening = match List.assoc_opt "opening" game_fields with
                            | Some (`Assoc opening_fields) ->
                                (match List.assoc_opt "name" opening_fields with
                                 | Some (`String s) -> Some s
                                 | _ -> None)
                            | _ -> None in
                          let time_class = match List.assoc_opt "time_class" game_fields with
                            | Some (`String s) -> Some s
                            | _ -> None in
                          let rules = match List.assoc_opt "rules" game_fields with
                            | Some (`String s) -> Some s
                            | _ -> Some "chess" in
                          let tournament = match List.assoc_opt "tournament" game_fields with
                            | Some (`String s) -> Some s
                            | _ -> None in
                          let game = {
                            id = "unknown";
                            white;
                            black;
                            pgn;
                            winner;
                            speed;
                            game_state;
                            created_at;
                            rating_white;
                            rating_black;
                            time_control;
                            variant;
                            opening;
                            end_time;
                            time_class;
                            rules;
                            tournament
                          } in
                          (* Фильтруем по rated_match если указан *)
                          let should_include = match rated_match with
                            | Some filter_rated -> 
                                (* Проверяем, есть ли рейтинги у игроков *)
                                (match game.rating_white, game.rating_black with
                                 | Some _, Some _ -> filter_rated
                                 | None, None -> not filter_rated
                                 | _ -> true)
                            | None -> true in
                          if should_include then game :: acc else acc
                      | _ -> acc
                    ) [] games in
                  parse_games game_list
              | _ -> [] in
            Lwt.return games
        | _ -> Lwt.return []
      with _ -> Lwt.return []
  | _ -> Lwt.return []

(** Get player statistics *)
let get_player_stats username =
  let url = Printf.sprintf "https://api.chess.com/pub/player/%s/stats" username in
  let* response, body = Cohttp_lwt_unix.Client.get (Uri.of_string url) in
  let* _body_str = Cohttp_lwt.Body.to_string body in
  match Cohttp.Response.status response with
  | `OK ->
      try
        let json = Yojson.Basic.from_string _body_str in
        match json with
        | `Assoc fields ->
            let chess_daily = match List.assoc_opt "chess_daily" fields with
              | Some (`Assoc daily_fields) ->
                  let last = match List.assoc_opt "last" daily_fields with
                    | Some (`Assoc last_fields) ->
                        let rating = match List.assoc_opt "rating" last_fields with
                          | Some (`Int i) -> i
                          | _ -> 0 in
                        let date = match List.assoc_opt "date" last_fields with
                          | Some (`Int i) -> i
                          | _ -> 0 in
                        { rating; date }
                      | _ -> { rating = 0; date = 0 }
                    | _ -> { rating = 0; date = 0 } in
                  let best = match List.assoc_opt "best" daily_fields with
                    | Some (`Assoc best_fields) ->
                        let rating = match List.assoc_opt "rating" best_fields with
                          | Some (`Int i) -> i
                          | _ -> 0 in
                        let date = match List.assoc_opt "date" best_fields with
                          | Some (`Int i) -> i
                          | _ -> 0 in
                        { rating; date }
                      | _ -> { rating = 0; date = 0 }
                    | _ -> { rating = 0; date = 0 } in
                  let record = match List.assoc_opt "record" daily_fields with
                    | Some (`Assoc record_fields) ->
                        let win = match List.assoc_opt "win" record_fields with
                          | Some (`Int i) -> i
                          | _ -> 0 in
                        let loss = match List.assoc_opt "loss" record_fields with
                          | Some (`Int i) -> i
                          | _ -> 0 in
                        let draw = match List.assoc_opt "draw" record_fields with
                          | Some (`Int i) -> i
                          | _ -> 0 in
                        { win; loss; draw }
                      | _ -> { win = 0; loss = 0; draw = 0 }
                    | _ -> { win = 0; loss = 0; draw = 0 } in
                  { last; best; record }
                | _ -> { last = { rating = 0; date = 0 }; best = { rating = 0; date = 0 }; record = { win = 0; loss = 0; draw = 0 } }
              | _ -> { last = { rating = 0; date = 0 }; best = { rating = 0; date = 0 }; record = { win = 0; loss = 0; draw = 0 } } in
            let stats = {
              total_games = 0;
              wins = 0;
              losses = 0;
              draws = 0;
              win_rate = 0.0;
              rating_avg = 0;
              best_rating = 0;
              current_rating = 0;
              rapid_games = 0;
              blitz_games = 0;
              bullet_games = 0;
              rapid_rating = None;
              blitz_rating = None;
              bullet_rating = None
            } in
            Lwt.return (Some stats)
        | _ -> Lwt.return_none
      with _ -> Lwt.return_none
  | _ -> Lwt.return_none



(** Get games from specific archive *)
let get_games_from_archive archive_url =
  let* response, body = Cohttp_lwt_unix.Client.get (Uri.of_string archive_url) in
  let* _body_str = Cohttp_lwt.Body.to_string body in
  match Cohttp.Response.status response with
  | `OK ->
      try
        let json = Yojson.Basic.from_string _body_str in
        match json with
        | `List games ->
            let parse_games (games : Yojson.Basic.t list) =
              List.fold_left (fun acc game ->
                match game with
                | `Assoc game_fields ->
                    let white = match List.assoc_opt "white" game_fields with
                      | Some (`String s) -> s
                      | _ -> "Unknown" in
                    let black = match List.assoc_opt "black" game_fields with
                      | Some (`String s) -> s
                      | _ -> "Unknown" in
                    let winner = match List.assoc_opt "winner" game_fields with
                      | Some (`String s) -> Some s
                      | _ -> None in
                    let pgn = match List.assoc_opt "pgn" game_fields with
                      | Some (`String s) -> s
                      | _ -> "" in
                    let time_control = match List.assoc_opt "time_control" game_fields with
                      | Some (`String s) -> Some s
                      | Some (`Int i) -> Some (string_of_int i)
                      | _ -> None in
                    let end_time = match List.assoc_opt "end_time" game_fields with
                      | Some (`Int i) -> Some (Int64.of_int i)
                      | _ -> None in
                    let speed = match List.assoc_opt "time_class" game_fields with
                      | Some (`String s) -> s
                      | _ -> "rapid" in
                    let game_state = match List.assoc_opt "status" game_fields with
                      | Some (`String s) -> s
                      | _ -> "finished" in
                    let created_at = match List.assoc_opt "created_at" game_fields with
                      | Some (`Int i) -> Int64.of_int i
                      | _ -> Int64.of_int (Unix.time () |> int_of_float) in
                    let rating_white = match List.assoc_opt "white_rating" game_fields with
                      | Some (`Int i) -> Some i
                      | _ -> None in
                    let rating_black = match List.assoc_opt "black_rating" game_fields with
                      | Some (`Int i) -> Some i
                      | _ -> None in
                    let variant = match List.assoc_opt "variant" game_fields with
                      | Some (`String s) -> Some s
                      | _ -> Some "standard" in
                    let opening = match List.assoc_opt "opening" game_fields with
                      | Some (`Assoc opening_fields) ->
                          (match List.assoc_opt "name" opening_fields with
                           | Some (`String s) -> Some s
                           | _ -> None)
                      | _ -> None in
                    let time_class = match List.assoc_opt "time_class" game_fields with
                      | Some (`String s) -> Some s
                      | _ -> None in
                    let rules = match List.assoc_opt "rules" game_fields with
                      | Some (`String s) -> Some s
                      | _ -> Some "chess" in
                    let tournament = match List.assoc_opt "tournament" game_fields with
                      | Some (`String s) -> Some s
                      | _ -> None in
                    let game = {
                      id = "unknown";
                      white;
                      black;
                      pgn;
                      winner;
                      speed;
                      game_state;
                      created_at;
                      rating_white;
                      rating_black;
                      time_control;
                      variant;
                      opening;
                      end_time;
                      time_class;
                      rules;
                      tournament
                    } in
                    game :: acc
                | _ -> acc
              ) [] games in
            let games = parse_games games in
            Lwt.return games
        | _ -> Lwt.return []
      with _ -> Lwt.return []
  | _ -> Lwt.return []



(** Get daily puzzle *)
let get_daily_puzzle () =
  let url = "https://api.chess.com/pub/puzzle" in
  let* response, body = Cohttp_lwt_unix.Client.get (Uri.of_string url) in
  let* _body_str = Cohttp_lwt.Body.to_string body in
  match Cohttp.Response.status response with
  | `OK ->
      try
        let json = Yojson.Basic.from_string _body_str in
        match json with
        | `Assoc fields ->
            let title = match List.assoc_opt "title" fields with
              | Some (`String s) -> s
              | _ -> "Unknown Puzzle" in
            let puzzle = {
              title;
              fen = ""; (* Chess.com API не предоставляет FEN для головоломок *)
              solution = [] (* Chess.com API не предоставляет решение *)
            } in
            Lwt.return (Some puzzle)
        | _ -> Lwt.return_none
      with _ -> Lwt.return_none
  | _ -> Lwt.return_none

(** Get leaderboards *)
let get_leaderboards () =
  let url = "https://api.chess.com/pub/leaderboards" in
  
  let* (response, body) = Cohttp_lwt_unix.Client.get (Uri.of_string url) in
  let* body_str = Cohttp_lwt.Body.to_string body in
  
  match Cohttp.Response.status response with
  | `OK ->
      try
        let json = Yojson.Basic.from_string body_str in
        match json with
        | `Assoc fields ->
            let daily_field = List.assoc "daily" fields in
            (match daily_field with
             | `List player_list ->
                 let all_players = List.map (function
                   | `Assoc player_fields ->
                       let username = match List.assoc "username" player_fields with `String s -> s | _ -> "Unknown" in
                       let score = match List.assoc "score" player_fields with `Int i -> i | _ -> 0 in
                       (username, score)
                   | _ -> ("Unknown", 0)
                 ) player_list in
                 let players = List.filteri (fun i _ -> i < 3) all_players in
                 Lwt.return [("daily", players)]
             | _ -> Lwt.return [])
        | _ -> Lwt.return []
      with _ -> Lwt.return []
  | _ ->
      Lwt.return []
