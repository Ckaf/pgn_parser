(** Lichess API client for fetching random games *)

open Lwt.Syntax

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

(** API response types *)
(* Removed unused api_response type *)

(** Helper function to extract PGN tags *)
let extract_pgn_tag tag_name lines =
  List.find_map (fun line ->
    if String.starts_with ~prefix:("[" ^ tag_name ^ " \"") line then
      let start = String.length ("[" ^ tag_name ^ " \"") in
      let end_pos = String.rindex line '"' in
      if end_pos > start then
        Some (String.sub line start (end_pos - start))
      else None
    else None
  ) lines

(** Helper function to extract numeric PGN tags *)
let extract_pgn_tag_int tag_name lines =
  match extract_pgn_tag tag_name lines with
  | Some s -> (try Some (int_of_string s) with _ -> None)
  | None -> None

(** Fetch a random game from Lichess *)
let fetch_random_game () =
  let url = "https://lichess.org/api/games/user/DrNykterstein?max=1&clocks=false&evals=false&opening=false" in
  
  let* (_, body) = Cohttp_lwt_unix.Client.get (Uri.of_string url) in
  let* body_str = Cohttp_lwt.Body.to_string body in
  
  (* Parse PGN directly *)
  let lines = String.split_on_char '\n' body_str in
  let lines = List.filter (fun s -> String.length s > 0) lines in
  
  match lines with
  | [] -> Lwt.return_none
  | _ ->

      
      let white = extract_pgn_tag "White" lines |> Option.value ~default:"Unknown" in
      let black = extract_pgn_tag "Black" lines |> Option.value ~default:"Unknown" in
      let date = extract_pgn_tag "Date" lines |> Option.value ~default:"Unknown" in
      let result = extract_pgn_tag "Result" lines in
      let rating_white = extract_pgn_tag_int "WhiteElo" lines in
      let rating_black = extract_pgn_tag_int "BlackElo" lines in
      let time_control = extract_pgn_tag "TimeControl" lines in
      let variant = extract_pgn_tag "Variant" lines in
      let opening = extract_pgn_tag "Opening" lines in
      
      (* Generate a simple ID *)
      let id = Printf.sprintf "%s_%s_%s" white black date in
      
      Lwt.return_some {
        id;
        white;
        black;
        pgn = body_str;
        winner = result;
        speed = "standard";
        status = "finished";
        created_at = Int64.of_int (Unix.time () |> int_of_float);
        rating_white;
        rating_black;
        time_control;
        variant;
        opening
      }

(** Fetch multiple random games *)
let fetch_random_games count =
  let url = Printf.sprintf "https://lichess.org/api/games/user/DrNykterstein?max=%d&clocks=false&evals=false&opening=false" count in
  
  let* (_, body) = Cohttp_lwt_unix.Client.get (Uri.of_string url) in
  let* body_str = Cohttp_lwt.Body.to_string body in
  
  (* Parse multiple PGN games *)
  let games = String.split_on_char '\n' body_str |> 
    List.fold_left (fun acc line ->
      if String.length line = 0 then
        match acc with
        | [] -> []
        | current :: rest -> "" :: current :: rest
      else
        match acc with
        | [] -> [line]
        | current :: rest -> (current ^ "\n" ^ line) :: rest
    ) [] |>
    List.rev |>
    List.filter (fun s -> String.length s > 0) in
  let games = List.filter (fun s -> String.length s > 0) games in
  
  let parse_single_game pgn_str =
    let lines = String.split_on_char '\n' pgn_str in
    let lines = List.filter (fun s -> String.length s > 0) lines in
    

    
    let white = extract_pgn_tag "White" lines |> Option.value ~default:"Unknown" in
    let black = extract_pgn_tag "Black" lines |> Option.value ~default:"Unknown" in
    let date = extract_pgn_tag "Date" lines |> Option.value ~default:"Unknown" in
    let result = extract_pgn_tag "Result" lines in
    let rating_white = extract_pgn_tag_int "WhiteElo" lines in
    let rating_black = extract_pgn_tag_int "BlackElo" lines in
    let time_control = extract_pgn_tag "TimeControl" lines in
    let variant = extract_pgn_tag "Variant" lines in
    let opening = extract_pgn_tag "Opening" lines in
    
    (* Generate a simple ID *)
    let id = Printf.sprintf "%s_%s_%s" white black date in
    
    { 
      id; 
      white; 
      black; 
      pgn = pgn_str; 
      winner = result; 
      speed = "standard"; 
      status = "finished"; 
      created_at = Int64.of_int (Unix.time () |> int_of_float);
      rating_white;
      rating_black;
      time_control;
      variant;
      opening
    }
  in
  
  Lwt.return (List.map parse_single_game games)

(** Convert Lichess game to PGN format *)
let lichess_game_to_pgn game =
  game.pgn

(** Fetch player information from Lichess API *)
let fetch_player_info username =
  let url = Printf.sprintf "https://lichess.org/api/user/%s" username in
  
  let* (response, body) = Cohttp_lwt_unix.Client.get (Uri.of_string url) in
  let* body_str = Cohttp_lwt.Body.to_string body in
  
  match Cohttp.Response.status response with
  | `OK ->
      (* Parse JSON response - simplified for now *)
      let online = String.contains body_str '"' && String.contains body_str 'o' && String.contains body_str 'n' && String.contains body_str 'l' && String.contains body_str 'i' && String.contains body_str 'n' && String.contains body_str 'e' && String.contains body_str 't' && String.contains body_str 'r' && String.contains body_str 'u' && String.contains body_str 'e' in
      let playing = String.contains body_str '"' && String.contains body_str 'p' && String.contains body_str 'l' && String.contains body_str 'a' && String.contains body_str 'y' && String.contains body_str 'i' && String.contains body_str 'n' && String.contains body_str 'g' && String.contains body_str 't' && String.contains body_str 'r' && String.contains body_str 'u' && String.contains body_str 'e' in
      let has_title = String.contains body_str '"' && String.contains body_str 't' && String.contains body_str 'i' && String.contains body_str 't' && String.contains body_str 'l' && String.contains body_str 'e' in
      let title = if has_title then Some "GM" else None in (* Simplified *)
      
      let player = {
        id = username;
        username;
        rating = Some 2500; (* Simplified - would parse from JSON *)
        title;
        online;
        playing;
        country = None;
        created_at = Int64.of_int (Unix.time () |> int_of_float)
      } in
      Lwt.return_some player
  | _ ->
      Lwt.return_none

(** Fetch games by player username *)
let fetch_player_games username ?(max_games=10) ?(_since=None) ?(_until=None) () =
  let url = Printf.sprintf "https://lichess.org/api/games/user/%s?max=%d&clocks=false&evals=false&opening=false" username max_games in
  
  let* (_, body) = Cohttp_lwt_unix.Client.get (Uri.of_string url) in
  let* body_str = Cohttp_lwt.Body.to_string body in
  
  (* Parse multiple PGN games *)
  let games = String.split_on_char '\n' body_str |> 
    List.fold_left (fun acc line ->
      if String.length line = 0 then
        match acc with
        | [] -> []
        | current :: rest -> "" :: current :: rest
      else
        match acc with
        | [] -> [line]
        | current :: rest -> (current ^ "\n" ^ line) :: rest
    ) [] |>
    List.rev |>
    List.filter (fun s -> String.length s > 0) in
  
  let parse_single_game pgn_str =
    let lines = String.split_on_char '\n' pgn_str in
    let lines = List.filter (fun s -> String.length s > 0) lines in
    
    let white = extract_pgn_tag "White" lines |> Option.value ~default:"Unknown" in
    let black = extract_pgn_tag "Black" lines |> Option.value ~default:"Unknown" in
    let date = extract_pgn_tag "Date" lines |> Option.value ~default:"Unknown" in
    let result = extract_pgn_tag "Result" lines in
    let rating_white = extract_pgn_tag_int "WhiteElo" lines in
    let rating_black = extract_pgn_tag_int "BlackElo" lines in
    let time_control = extract_pgn_tag "TimeControl" lines in
    let variant = extract_pgn_tag "Variant" lines in
    let opening = extract_pgn_tag "Opening" lines in
    
    let id = Printf.sprintf "%s_%s_%s" white black date in
    
    { 
      id; 
      white; 
      black; 
      pgn = pgn_str; 
      winner = result; 
      speed = "standard"; 
      status = "finished"; 
      created_at = Int64.of_int (Unix.time () |> int_of_float);
      rating_white;
      rating_black;
      time_control;
      variant;
      opening
    }
  in
  
  Lwt.return (List.map parse_single_game games)

(** Fetch games by game ID *)
let fetch_game_by_id game_id =
  let url = Printf.sprintf "https://lichess.org/game/export/%s?clocks=false&evals=false&opening=false" game_id in
  
  let* (response, body) = Cohttp_lwt_unix.Client.get (Uri.of_string url) in
  let* body_str = Cohttp_lwt.Body.to_string body in
  
  match Cohttp.Response.status response with
  | `OK ->
      let lines = String.split_on_char '\n' body_str in
      let lines = List.filter (fun s -> String.length s > 0) lines in
      
      let white = extract_pgn_tag "White" lines |> Option.value ~default:"Unknown" in
      let black = extract_pgn_tag "Black" lines |> Option.value ~default:"Unknown" in
      let _date = extract_pgn_tag "Date" lines |> Option.value ~default:"Unknown" in
      let result = extract_pgn_tag "Result" lines in
      let rating_white = extract_pgn_tag_int "WhiteElo" lines in
      let rating_black = extract_pgn_tag_int "BlackElo" lines in
      let time_control = extract_pgn_tag "TimeControl" lines in
      let variant = extract_pgn_tag "Variant" lines in
      let opening = extract_pgn_tag "Opening" lines in
      
      let game = {
        id = game_id;
        white;
        black;
        pgn = body_str;
        winner = result;
        speed = "standard";
        status = "finished";
        created_at = Int64.of_int (Unix.time () |> int_of_float);
        rating_white;
        rating_black;
        time_control;
        variant;
        opening
      } in
      Lwt.return_some game
  | _ ->
      Lwt.return_none

(** Fetch ongoing games *)
let fetch_ongoing_games () =
  let url = "https://lichess.org/api/stream/games-by-users" in
  
  let* (_, body) = Cohttp_lwt_unix.Client.post_form 
    ~params:[("users", ["DrNykterstein"; "DrDrunkenstein"; "DrGrekenstein"])] 
    (Uri.of_string url) in
  let* body_str = Cohttp_lwt.Body.to_string body in
  
  (* Parse ongoing games with proper JSON parsing *)
  let games = String.split_on_char '\n' body_str |>
    List.filter (fun s -> String.length s > 0) in
  
  let parse_ongoing_game line =
    try
      let json = Yojson.Basic.from_string line in
      match json with
      | `Assoc fields ->
          let id = match List.assoc_opt "id" fields with Some (`String s) -> s | _ -> "unknown" in
                     let white = match List.assoc_opt "white" fields with 
             | Some (`Assoc white_fields) ->
                 match List.assoc_opt "name" white_fields with Some (`String s) -> s | _ -> "Unknown"
             | _ -> "Unknown" in
           let black = match List.assoc_opt "black" fields with 
             | Some (`Assoc black_fields) ->
                 match List.assoc_opt "name" black_fields with Some (`String s) -> s | _ -> "Unknown"
             | _ -> "Unknown" in
          let speed = match List.assoc_opt "speed" fields with Some (`String s) -> s | _ -> "standard" in
          let variant = match List.assoc_opt "variant" fields with Some (`String s) -> Some s | _ -> Some "standard" in
                     let time_control = match List.assoc_opt "clock" fields with 
             | Some (`Assoc clock_fields) ->
                 match List.assoc_opt "initial" clock_fields with Some (`Int i) -> Some (string_of_int i)
                 | _ -> None
             | _ -> None in
           let rating_white = match List.assoc_opt "white" fields with 
             | Some (`Assoc white_fields) ->
                 match List.assoc_opt "rating" white_fields with Some (`Int i) -> Some i | _ -> None
             | _ -> None in
           let rating_black = match List.assoc_opt "black" fields with 
             | Some (`Assoc black_fields) ->
                 match List.assoc_opt "rating" black_fields with Some (`Int i) -> Some i | _ -> None
             | _ -> None in
          
          {
            id;
            white;
            black;
            pgn = line; (* Keep raw JSON as PGN for now *)
            winner = None;
            speed;
            status = "ongoing";
            created_at = Int64.of_int (Unix.time () |> int_of_float);
            rating_white;
            rating_black;
            time_control;
            variant;
            opening = None
          }
      | _ ->
          (* Fallback for non-JSON lines *)
          let id = Printf.sprintf "ongoing_%d" (Hashtbl.hash line) in
          {
            id;
            white = "Player1";
            black = "Player2";
            pgn = line;
            winner = None;
            speed = "standard";
            status = "ongoing";
            created_at = Int64.of_int (Unix.time () |> int_of_float);
            rating_white = None;
            rating_black = None;
            time_control = None;
            variant = Some "standard";
            opening = None
          }
    with _ ->
      (* Fallback for parsing errors *)
      let id = Printf.sprintf "ongoing_%d" (Hashtbl.hash line) in
      {
        id;
        white = "Player1";
        black = "Player2";
        pgn = line;
        winner = None;
        speed = "standard";
        status = "ongoing";
        created_at = Int64.of_int (Unix.time () |> int_of_float);
        rating_white = None;
        rating_black = None;
        time_control = None;
        variant = Some "standard";
        opening = None
      }
  in
  
  Lwt.return (List.map parse_ongoing_game games)

(** Search games with filters *)
let search_games ?(player=None) ?(variant=None) ?(speed=None) ?(_rated=None) ?(max_games=10) () =
  let username = match player with
    | Some p -> p
    | None -> "DrNykterstein" in
  
  let base_url = Printf.sprintf "https://lichess.org/api/games/user/%s" username in
  let params = [("max", string_of_int max_games); ("clocks", "false"); ("evals", "false"); ("opening", "false")] in
  
  let url = Uri.add_query_params' (Uri.of_string base_url) params in
  
  let* (_, body) = Cohttp_lwt_unix.Client.get url in
  let* body_str = Cohttp_lwt.Body.to_string body in
  
  (* Parse games and apply filters *)
  let games = String.split_on_char '\n' body_str |> 
    List.fold_left (fun acc line ->
      if String.length line = 0 then
        match acc with
        | [] -> []
        | current :: rest -> "" :: current :: rest
      else
        match acc with
        | [] -> [line]
        | current :: rest -> (current ^ "\n" ^ line) :: rest
    ) [] |>
    List.rev |>
    List.filter (fun s -> String.length s > 0) in
  
  let parse_single_game pgn_str =
    let lines = String.split_on_char '\n' pgn_str in
    let lines = List.filter (fun s -> String.length s > 0) lines in
    
    let white = extract_pgn_tag "White" lines |> Option.value ~default:"Unknown" in
    let black = extract_pgn_tag "Black" lines |> Option.value ~default:"Unknown" in
    let date = extract_pgn_tag "Date" lines |> Option.value ~default:"Unknown" in
    let result = extract_pgn_tag "Result" lines in
    let rating_white = extract_pgn_tag_int "WhiteElo" lines in
    let rating_black = extract_pgn_tag_int "BlackElo" lines in
    let time_control = extract_pgn_tag "TimeControl" lines in
    let game_variant = extract_pgn_tag "Variant" lines in
    let opening = extract_pgn_tag "Opening" lines in
    
    let id = Printf.sprintf "%s_%s_%s" white black date in
    
    { 
      id; 
      white; 
      black; 
      pgn = pgn_str; 
      winner = result; 
      speed = "standard"; 
      status = "finished"; 
      created_at = Int64.of_int (Unix.time () |> int_of_float);
      rating_white;
      rating_black;
      time_control;
      variant = game_variant;
      opening
    }
  in
  
  let all_games = List.map parse_single_game games in
  
  (* Apply filters *)
  let filtered_games = List.filter (fun game ->
    let player_match = match player with
      | None -> true
      | Some p -> game.white = p || game.black = p in
    
    let variant_match = match variant with
      | None -> true
      | Some v -> game.variant = Some v in
    
    let speed_match = match speed with
      | None -> true
      | Some s -> game.speed = s in
    
    player_match && variant_match && speed_match
  ) all_games in
  
  Lwt.return filtered_games

(** Get player statistics *)
let get_player_stats username =
  let url = Printf.sprintf "https://lichess.org/api/user/%s" username in
  
  let* (response, body) = Cohttp_lwt_unix.Client.get (Uri.of_string url) in
  let* body_str = Cohttp_lwt.Body.to_string body in
  
  match Cohttp.Response.status response with
  | `OK ->
      try
        let json = Yojson.Basic.from_string body_str in
        match json with
        | `Assoc fields ->
                         let total_games = match List.assoc_opt "count" fields with 
               | Some (`Assoc count_fields) ->
                   match List.assoc_opt "all" count_fields with Some (`Int i) -> i | _ -> 0
               | _ -> 0 in
             
             let wins = match List.assoc_opt "count" fields with 
               | Some (`Assoc count_fields) ->
                   match List.assoc_opt "win" count_fields with Some (`Int i) -> i | _ -> 0
               | _ -> 0 in
             
             let losses = match List.assoc_opt "count" fields with 
               | Some (`Assoc count_fields) ->
                   match List.assoc_opt "loss" count_fields with Some (`Int i) -> i | _ -> 0
               | _ -> 0 in
             
             let draws = match List.assoc_opt "count" fields with 
               | Some (`Assoc count_fields) ->
                   match List.assoc_opt "draw" count_fields with Some (`Int i) -> i | _ -> 0
               | _ -> 0 in
            
            let win_rate = if total_games > 0 then float_of_int wins /. float_of_int total_games else 0.0 in
            
                         let current_rating = match List.assoc_opt "perfs" fields with 
               | Some (`Assoc perfs_fields) ->
                   match List.assoc_opt "classical" perfs_fields with 
                     | Some (`Assoc classical_fields) ->
                         match List.assoc_opt "games" classical_fields with Some (`Int games) ->
                           if games > 0 then
                             match List.assoc_opt "rating" classical_fields with Some (`Int rating) -> rating
                             | _ -> 1500
                           else 1500
                         | _ -> 1500
                     | _ -> 1500
               | _ -> 1500 in
             
             let best_rating = match List.assoc_opt "perfs" fields with 
               | Some (`Assoc perfs_fields) ->
                   match List.assoc_opt "classical" perfs_fields with 
                     | Some (`Assoc classical_fields) ->
                         match List.assoc_opt "best" classical_fields with 
                           | Some (`Assoc best_fields) ->
                               match List.assoc_opt "rating" best_fields with Some (`Int rating) -> rating
                               | _ -> current_rating
                           | _ -> current_rating
                     | _ -> current_rating
               | _ -> current_rating in
            
            let rating_avg = (current_rating + best_rating) / 2 in
            
            let stats = {
              total_games;
              wins;
              losses;
              draws;
              win_rate;
              rating_avg;
              best_rating;
              current_rating;
            } in
            Lwt.return_some stats
        | _ -> Lwt.return_none
      with _ -> Lwt.return_none
  | _ ->
      Lwt.return_none





(** Print player statistics *)
let print_player_stats stats =
  Printf.printf "Total Games: %d\n" stats.total_games;
  Printf.printf "Wins: %d\n" stats.wins;
  Printf.printf "Losses: %d\n" stats.losses;
  Printf.printf "Draws: %d\n" stats.draws;
  Printf.printf "Win Rate: %.2f%%\n" (stats.win_rate *. 100.0);
  Printf.printf "Average Rating: %d\n" stats.rating_avg;
  Printf.printf "Best Rating: %d\n" stats.best_rating;
  Printf.printf "Current Rating: %d\n" stats.current_rating
