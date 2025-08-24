open Lwt.Syntax
open Pgn_parser
open Lichess_api

(** Demo for expanded Lichess API features *)
let demo_fetch_random_game () =
  Printf.printf "\n=== Fetching Random Game ===\n";
  
  let* game_opt = fetch_random_game () in
  match game_opt with
  | Some game ->
      Printf.printf "✅ Fetched game: %s vs %s\n" game.white game.black;
      Printf.printf "   ID: %s\n" game.id;
      Printf.printf "   Speed: %s, Status: %s\n" game.speed game.status;
      (match game.rating_white with
       | Some r -> Printf.printf "   White rating: %d\n" r
       | None -> ());
      (match game.rating_black with
       | Some r -> Printf.printf "   Black rating: %d\n" r
       | None -> ());
      (match game.opening with
       | Some o -> Printf.printf "   Opening: %s\n" o
       | None -> ());
      Printf.printf "   PGN length: %d chars\n" (String.length game.pgn);
      
      (* Try to parse *)
      (match parse_game game.pgn with
       | Ok parsed_game ->
           Printf.printf "   ✅ Parsed: %d moves\n" (List.length parsed_game.moves)
       | Error e ->
           Printf.printf "   ❌ Parse failed: %s\n" (match e with
             | InvalidMove s -> s | InvalidTag s -> s 
             | InvalidFormat s -> s | UnexpectedEnd s -> s));
      Lwt.return ()
  | None ->
      Printf.printf "❌ Failed to fetch game\n";
      Lwt.return ()

let demo_fetch_multiple_games () =
  Printf.printf "\n=== Fetching Multiple Games ===\n";
  
  let* games = fetch_random_games 3 in
  Printf.printf "✅ Fetched %d games\n" (List.length games);
  
  List.iteri (fun i game ->
    Printf.printf "Game %d: %s vs %s\n" (i + 1) game.white game.black;
    Printf.printf "  ID: %s\n" game.id;
    Printf.printf "  Speed: %s, Status: %s\n" game.speed game.status;
    (match game.rating_white with
     | Some r -> Printf.printf "  White rating: %d\n" r
     | None -> ());
    (match game.rating_black with
     | Some r -> Printf.printf "  Black rating: %d\n" r
     | None -> ());
    Printf.printf "  PGN length: %d chars\n" (String.length game.pgn);
    
    (* Try to parse *)
    match parse_game game.pgn with
    | Ok parsed_game ->
        Printf.printf "  ✅ Parsed: %d moves\n" (List.length parsed_game.moves)
    | Error _ ->
        Printf.printf "  ❌ Parse failed\n"
  ) games;
  Lwt.return ()

let demo_player_info () =
  Printf.printf "\n=== Player Information ===\n";
  
  let* player_opt = fetch_player_info "DrNykterstein" in
  match player_opt with
  | Some player ->
      Printf.printf "✅ Player: %s\n" player.username;
      Printf.printf "   ID: %s\n" player.id;
      (match player.rating with
       | Some r -> Printf.printf "   Rating: %d\n" r
       | None -> Printf.printf "   Rating: Unknown\n");
      (match player.title with
       | Some t -> Printf.printf "   Title: %s\n" t
       | None -> Printf.printf "   Title: None\n");
      Printf.printf "   Online: %s\n" (if player.online then "Yes" else "No");
      Printf.printf "   Playing: %s\n" (if player.playing then "Yes" else "No");
      Lwt.return ()
  | None ->
      Printf.printf "❌ Failed to fetch player info\n";
      Lwt.return ()

let demo_player_stats () =
  Printf.printf "\n=== Player Statistics ===\n";
  
  let* stats_opt = get_player_stats "DrNykterstein" in
  match stats_opt with
  | Some stats ->
      Printf.printf "✅ Player stats:\n";
      Printf.printf "   Total games: %d\n" stats.total_games;
      Printf.printf "   Wins: %d, Losses: %d, Draws: %d\n" stats.wins stats.losses stats.draws;
      Printf.printf "   Win rate: %.1f%%\n" (stats.win_rate *. 100.0);
      Printf.printf "   Average rating: %d\n" stats.rating_avg;
      Printf.printf "   Best rating: %d\n" stats.best_rating;
      Printf.printf "   Current rating: %d\n" stats.current_rating;
      Lwt.return ()
  | None ->
      Printf.printf "❌ Failed to fetch player stats\n";
      Lwt.return ()

let demo_search_games () =
  Printf.printf "\n=== Search Games ===\n";
  
  let* games = search_games ~player:(Some "DrNykterstein") ~max_games:2 () in
  Printf.printf "✅ Found %d games for DrNykterstein\n" (List.length games);
  
  List.iteri (fun i game ->
    Printf.printf "Game %d: %s vs %s\n" (i + 1) game.white game.black;
    Printf.printf "  ID: %s\n" game.id;
    Printf.printf "  Speed: %s, Status: %s\n" game.speed game.status;
    (match game.variant with
     | Some v -> Printf.printf "  Variant: %s\n" v
     | None -> ());
    (match game.opening with
     | Some o -> Printf.printf "  Opening: %s\n" o
     | None -> ());
    Printf.printf "  PGN length: %d chars\n" (String.length game.pgn)
  ) games;
  Lwt.return ()

(** Main demo function *)
let () =
  Printf.printf "🎯 PGN Parser - Lichess API Demo\n";
  Printf.printf "================================\n";
  
  let run_demos () =
    let* () = demo_fetch_random_game () in
    let* () = demo_fetch_multiple_games () in
    let* () = demo_player_info () in
    let* () = demo_player_stats () in
    let* () = demo_search_games () in
    
    Printf.printf "\n✅ All demos completed!\n";
    Lwt.return ()
  in
  
  let _ = Lwt_main.run (run_demos ()) in
  exit 0

