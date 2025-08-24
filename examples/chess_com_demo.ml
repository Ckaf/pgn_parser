open Pgn_parser
open Chess_com_api

(** Demo for Chess.com API functionality *)

(** Demo basic Chess.com API features *)
let demo_basic_features () =
  Printf.printf "🎯 Chess.com API Demo\n";
  Printf.printf "====================\n\n";
  
  Printf.printf "=== Basic API Features ===\n";
  
  (* Test fetching a random game *)
  Printf.printf "Fetching a random game...\n";
  let game_opt = Lwt_main.run (fetch_random_game ()) in
  match game_opt with
  | Some game ->
      Printf.printf "✅ Successfully fetched game:\n";
      Printf.printf "   ID: %s\n" game.id;
      Printf.printf "   White: %s\n" game.white;
      Printf.printf "   Black: %s\n" game.black;
      Printf.printf "   Speed: %s\n" game.speed;
      Printf.printf "   Status: %s\n" game.game_state;
      Printf.printf "   PGN length: %d chars\n" (String.length game.pgn);
      
      (* Test parsing the PGN *)
      (match parse_game game.pgn with
       | Ok parsed_game ->
           Printf.printf "✅ Successfully parsed PGN:\n";
           Printf.printf "   Parsed moves: %d\n" (List.length parsed_game.moves);
           Printf.printf "   White: %s\n" (match parsed_game.info.white with Some w -> w.name | None -> "Unknown");
           Printf.printf "   Black: %s\n" (match parsed_game.info.black with Some b -> b.name | None -> "Unknown");
           Printf.printf "   Event: %s\n" (match parsed_game.info.event with Some e -> e | None -> "Unknown");
       | Error e ->
           Printf.printf "❌ Failed to parse PGN: ";
           pp_error Format.std_formatter e;
           Printf.printf "\n");
      ()
  | None ->
      Printf.printf "❌ Failed to fetch random game\n"

(** Demo player information *)
let demo_player_info () =
  Printf.printf "\n=== Player Information ===\n";
  
  Printf.printf "Fetching player info for 'hikaru'...\n";
  let player_opt = Lwt_main.run (fetch_player_info "hikaru") in
  match player_opt with
  | Some player ->
      Printf.printf "✅ Successfully fetched player info:\n";
      Printf.printf "   Username: %s\n" player.username;
      Printf.printf "   Rating: %s\n" (match player.rating with Some r -> string_of_int r | None -> "Unknown");
      Printf.printf "   Title: %s\n" (match player.title with Some t -> t | None -> "None");
      Printf.printf "   Online: %s\n" (if player.online then "Yes" else "No");
      Printf.printf "   Playing: %s\n" (if player.playing then "Yes" else "No");
      Printf.printf "   Followers: %s\n" (match player.followers with Some f -> string_of_int f | None -> "Unknown");
      Printf.printf "   Is streamer: %s\n" (if player.is_streamer then "Yes" else "No");
      Printf.printf "   Is verified: %s\n" (if player.is_verified then "Yes" else "No");
  | None ->
      Printf.printf "❌ Failed to fetch player info\n"

(** Demo player games *)
let demo_player_games () =
  Printf.printf "\n=== Player Games ===\n";
  
  Printf.printf "Fetching games for 'hikaru'...\n";
  let games = Lwt_main.run (fetch_player_games "hikaru" ~max_games:3 ()) in
  Printf.printf "✅ Fetched %d games:\n" (List.length games);
  
  List.iteri (fun i game ->
    Printf.printf "   Game %d: %s vs %s (%s)\n" (i + 1) game.white game.black game.speed;
    
    (* Test parsing each game's PGN *)
    match parse_game game.pgn with
    | Ok parsed_game ->
        Printf.printf "     Parsed moves: %d\n" (List.length parsed_game.moves)
    | Error _ ->
        Printf.printf "     Failed to parse PGN\n"
  ) games

(** Demo player statistics *)
let demo_player_stats () =
  Printf.printf "\n=== Player Statistics ===\n";
  
  Printf.printf "Fetching stats for 'hikaru'...\n";
  let stats_opt = Lwt_main.run (get_player_stats "hikaru") in
  match stats_opt with
  | Some stats ->
      Printf.printf "✅ Successfully fetched player stats:\n";
      Printf.printf "   Total games: %d\n" stats.total_games;
      Printf.printf "   Wins: %d, Losses: %d, Draws: %d\n" stats.wins stats.losses stats.draws;
      Printf.printf "   Win rate: %.1f%%\n" (stats.win_rate *. 100.0);
      Printf.printf "   Current rating: %d\n" stats.current_rating;
      Printf.printf "   Best rating: %d\n" stats.best_rating;
      Printf.printf "   Rapid games: %d\n" stats.rapid_games;
      Printf.printf "   Blitz games: %d\n" stats.blitz_games;
      Printf.printf "   Bullet games: %d\n" stats.bullet_games;
  | None ->
      Printf.printf "❌ Failed to fetch player stats\n"

(** Demo search functionality *)
let demo_search () =
  Printf.printf "\n=== Search Games ===\n";
  
  Printf.printf "Searching for rapid games by 'hikaru'...\n";
  let games = Lwt_main.run (search_games ~rated_match:(Some true) ()) in
  Printf.printf "✅ Found %d rapid games:\n" (List.length games);
  
  List.iteri (fun i game ->
    Printf.printf "   Game %d: %s vs %s (%s)\n" (i + 1) game.white game.black game.speed
  ) games

(** Demo archives *)
let demo_archives () =
  Printf.printf "\n=== Player Archives ===\n";
  
  Printf.printf "Fetching archives for 'hikaru'...\n";
  let archives = Lwt_main.run (get_player_archives "hikaru") in
  Printf.printf "✅ Fetched %d archives:\n" (List.length archives);
  
  List.iteri (fun i archive ->
    if i < 5 then
      Printf.printf "   Archive %d: %s\n" (i + 1) archive
  ) archives

(** Demo leaderboards *)
let demo_leaderboards () =
  Printf.printf "\n=== Leaderboards ===\n";
  
  Printf.printf "Fetching leaderboards...\n";
  let leaderboards = Lwt_main.run (get_leaderboards ()) in
  Printf.printf "✅ Fetched %d leaderboards:\n" (List.length leaderboards);
  
  List.iter (fun (category, players) ->
    Printf.printf "   %s: %d players\n" category (List.length players);
    List.iteri (fun i (name, rating) ->
      if i < 3 then
        Printf.printf "     %d. %s (%d)\n" (i + 1) name rating
    ) players
  ) leaderboards

(** Demo daily puzzle *)
let demo_daily_puzzle () =
  Printf.printf "\n=== Daily Puzzle ===\n";
  
  Printf.printf "Fetching daily puzzle...\n";
  let puzzle_opt = Lwt_main.run (get_daily_puzzle ()) in
  match puzzle_opt with
  | Some puzzle ->
      Printf.printf "✅ Successfully fetched daily puzzle:\n";
      Printf.printf "   Title: %s\n" puzzle.title;
      Printf.printf "   FEN: %s\n" puzzle.fen;
  | None ->
      Printf.printf "❌ Failed to fetch daily puzzle\n"

(** Demo error handling *)
let demo_error_handling () =
  Printf.printf "\n=== Error Handling ===\n";
  
  Printf.printf "Testing with invalid player name...\n";
  let player_opt = Lwt_main.run (fetch_player_info "invalid_player_name_that_does_not_exist_12345") in
  match player_opt with
  | Some _ ->
      Printf.printf "⚠️  Unexpected success for invalid player\n"
  | None ->
      Printf.printf "✅ Correctly handled invalid player\n"

(** Demo data structure compatibility *)
let demo_data_compatibility () =
  Printf.printf "\n=== Data Structure Compatibility ===\n";
  
  (* Create a test game *)
  let test_game = {
    id = "demo_test";
    white = "DemoPlayer";
    black = "DemoOpponent";
    pgn = "[Event \"Demo Game\"]\n[White \"DemoPlayer\"]\n[Black \"DemoOpponent\"]\n\n1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Bxc6 dxc6 5. O-O 1-0";
    winner = Some "1-0";
    speed = "rapid";
    game_state = "finished";
    created_at = Int64.of_int 1234567890;
    rating_white = Some 2500;
    rating_black = Some 2400;
    time_control = Some "600";
    variant = Some "standard";
    opening = Some "Ruy Lopez";
    end_time = Some (Int64.of_int 1234567890);
    time_class = Some "rapid";
    rules = Some "chess";
    tournament = None;
  } in
  
  Printf.printf "✅ Created test game:\n";
  Printf.printf "   White: %s\n" test_game.white;
  Printf.printf "   Black: %s\n" test_game.black;
  Printf.printf "   Speed: %s\n" test_game.speed;
  Printf.printf "   Time class: %s\n" (Option.value ~default:"None" test_game.time_class);
  Printf.printf "   Rules: %s\n" (Option.value ~default:"None" test_game.rules);
  
  (* Convert to PGN and parse back *)
  let converted_pgn = chess_com_game_to_pgn test_game in
  Printf.printf "✅ Converted to PGN (length: %d chars)\n" (String.length converted_pgn);
  
  match parse_game converted_pgn with
  | Ok parsed_game ->
      Printf.printf "✅ Successfully parsed converted PGN:\n";
      Printf.printf "   Parsed moves: %d\n" (List.length parsed_game.moves);
      Printf.printf "   White: %s\n" (match parsed_game.info.white with Some w -> w.name | None -> "Unknown");
      Printf.printf "   Black: %s\n" (match parsed_game.info.black with Some b -> b.name | None -> "Unknown");
      Printf.printf "   Event: %s\n" (match parsed_game.info.event with Some e -> e | None -> "Unknown");
  | Error e ->
      Printf.printf "❌ Failed to parse converted PGN: ";
      pp_error Format.std_formatter e;
      Printf.printf "\n"

(** Main demo runner *)
let () =
  Printf.printf "🎯 Chess.com API Demo\n";
  Printf.printf "====================\n\n";
  
  demo_basic_features ();
  demo_player_info ();
  demo_player_games ();
  demo_player_stats ();
  demo_search ();
  demo_archives ();
  demo_leaderboards ();
  demo_daily_puzzle ();
  demo_error_handling ();
  demo_data_compatibility ();
  
  Printf.printf "\n🎉 Chess.com API demo completed!\n"
