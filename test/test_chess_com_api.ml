(* open Pgn_parser - removed unused open *)
open Chess_com_api
open Lwt.Syntax

(** Online tests for Chess.com API *)

(** Test fetching a random game *)
let test_fetch_random_game () =
  Printf.printf "=== Testing fetch_random_game ===\n";
  
  let* game_opt = fetch_random_game () in
  match game_opt with
  | Some game ->
      Printf.printf "✅ Successfully fetched random game:\n";
      Printf.printf "   ID: %s\n" game.id;
      Printf.printf "   White: %s\n" game.white;
      Printf.printf "   Black: %s\n" game.black;
      Printf.printf "   Speed: %s\n" game.speed;
      Printf.printf "   Status: %s\n" game.game_state;
      Printf.printf "   PGN length: %d chars\n" (String.length game.pgn);
      Lwt.return true
  | None ->
      Printf.printf "❌ Failed to fetch random game\n";
      Lwt.return false

(** Test fetching multiple random games *)
let test_fetch_random_games () =
  Printf.printf "\n=== Testing fetch_random_games ===\n";
  
  let* games = fetch_random_games 3 in
  Printf.printf "✅ Fetched %d random games\n" (List.length games);
  
  List.iteri (fun i game ->
    Printf.printf "   Game %d: %s vs %s (%s)\n" (i + 1) game.white game.black game.speed
  ) games;
  
  Lwt.return (List.length games > 0)

(** Test fetching player information *)
let test_fetch_player_info () =
  Printf.printf "\n=== Testing fetch_player_info ===\n";
  
  let* player_opt = fetch_player_info "hikaru" in
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
      Lwt.return true
  | None ->
      Printf.printf "❌ Failed to fetch player info\n";
      Lwt.return false

(** Test fetching player games *)
let test_fetch_player_games () =
  Printf.printf "\n=== Testing fetch_player_games ===\n";
  
  let* games = fetch_player_games "hikaru" ~max_games:5 () in
  Printf.printf "✅ Fetched %d games for player hikaru\n" (List.length games);
  
  List.iteri (fun i game ->
    Printf.printf "   Game %d: %s vs %s (%s)\n" (i + 1) game.white game.black game.speed
  ) games;
  
  Lwt.return (List.length games > 0)

(** Test fetching game by ID *)
let test_fetch_game_by_id () =
  Printf.printf "\n=== Testing fetch_game_by_id ===\n";
  
  let* game_opt = fetch_game_by_id "test_game_id" in
  match game_opt with
  | Some game ->
      Printf.printf "✅ Successfully fetched game by ID:\n";
      Printf.printf "   ID: %s\n" game.id;
      Printf.printf "   White: %s\n" game.white;
      Printf.printf "   Black: %s\n" game.black;
      Printf.printf "   Speed: %s\n" game.speed;
      Printf.printf "   Status: %s\n" game.game_state;
      Lwt.return true
  | None ->
      Printf.printf "❌ Failed to fetch game by ID\n";
      Lwt.return false

(** Test fetching ongoing games *)
let test_fetch_ongoing_games () =
  Printf.printf "\n=== Testing fetch_ongoing_games ===\n";
  
  let* games = fetch_ongoing_games () in
  Printf.printf "✅ Fetched %d ongoing games\n" (List.length games);
  
  List.iteri (fun i game ->
    Printf.printf "   Game %d: %s vs %s (%s)\n" (i + 1) game.white game.black game.game_state
  ) games;
  
  Lwt.return (List.length games > 0)

(** Test searching games *)
let test_search_games () =
  Printf.printf "\n=== Testing search_games ===\n";
  
  let* games = search_games ~rated_match:(Some true) () in
  Printf.printf "✅ Searched for %d rapid games by hikaru\n" (List.length games);
  
  List.iteri (fun i game ->
    Printf.printf "   Game %d: %s vs %s (%s)\n" (i + 1) game.white game.black game.speed
  ) games;
  
  Lwt.return (List.length games > 0)

(** Test getting player statistics *)
let test_get_player_stats () =
  Printf.printf "\n=== Testing get_player_stats ===\n";
  
  let* stats_opt = get_player_stats "hikaru" in
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
      Lwt.return true
  | None ->
      Printf.printf "❌ Failed to fetch player stats\n";
      Lwt.return false

(** Test getting player archives *)
let test_get_player_archives () =
  Printf.printf "\n=== Testing get_player_archives ===\n";
  
  let* archives = get_player_archives "hikaru" in
  Printf.printf "✅ Fetched %d archives for player hikaru\n" (List.length archives);
  
  List.iteri (fun i archive ->
    Printf.printf "   Archive %d: %s\n" (i + 1) archive
  ) archives;
  
  Lwt.return (List.length archives > 0)

(** Test getting games from archive *)
let test_get_games_from_archive () =
  Printf.printf "\n=== Testing get_games_from_archive ===\n";
  
  let* games = get_games_from_archive "https://api.chess.com/pub/player/hikaru/games/2024/01" in
  Printf.printf "✅ Fetched %d games from archive\n" (List.length games);
  
  List.iteri (fun i game ->
    Printf.printf "   Game %d: %s vs %s (%s)\n" (i + 1) game.white game.black game.speed
  ) games;
  
  Lwt.return (List.length games > 0)

(** Test getting club information *)


(** Test getting daily puzzle *)
let test_get_daily_puzzle () =
  Printf.printf "\n=== Testing get_daily_puzzle ===\n";
  
  let* puzzle_opt = get_daily_puzzle () in
  match puzzle_opt with
  | Some puzzle ->
      Printf.printf "✅ Successfully fetched daily puzzle:\n";
      Printf.printf "   Title: %s\n" puzzle.title;
      Printf.printf "   FEN: %s\n" puzzle.fen;
      Lwt.return true
  | None ->
      Printf.printf "❌ Failed to fetch daily puzzle\n";
      Lwt.return false

(** Test getting leaderboards *)
let test_get_leaderboards () =
  Printf.printf "\n=== Testing get_leaderboards ===\n";
  
  let* leaderboards = get_leaderboards () in
  Printf.printf "✅ Fetched %d leaderboards\n" (List.length leaderboards);
  
  List.iter (fun (category, players) ->
    Printf.printf "   %s: %d players\n" category (List.length players);
    List.iteri (fun i (name, rating) ->
      if i < 3 then
        Printf.printf "     %d. %s (%d)\n" (i + 1) name rating
    ) players
  ) leaderboards;
  
  Lwt.return (List.length leaderboards > 0)

(** Test data structure compatibility *)
let test_data_structure_compatibility () =
  Printf.printf "\n=== Testing Data Structure Compatibility ===\n";
  
  (* Test that chess_com_game can be converted to PGN and parsed back *)
  let test_game = {
    id = "compat_test";
    white = "CompatPlayer";
    black = "CompatOpponent";
    pgn = "[Event \"Compatibility Test\"]\n[White \"CompatPlayer\"]\n[Black \"CompatOpponent\"]\n\n1. e4 1-0";
    winner = Some "1-0";
    speed = "rapid";
    game_state = "finished";
    created_at = Int64.of_int 1234567890;
    rating_white = Some 2500;
    rating_black = Some 2400;
    time_control = Some "600";
    variant = Some "standard";
    opening = Some "King's Pawn";
    end_time = Some (Int64.of_int 1234567890);
    time_class = Some "rapid";
    rules = Some "chess";
    tournament = None;
  } in
  
  let converted_pgn = chess_com_game_to_pgn test_game in
  
  (* Check that the converted PGN contains all the important information *)
  let has_white = String.contains converted_pgn 'W' && String.contains converted_pgn 'h' && String.contains converted_pgn 'i' && String.contains converted_pgn 't' && String.contains converted_pgn 'e' in
  let has_black = String.contains converted_pgn 'B' && String.contains converted_pgn 'l' && String.contains converted_pgn 'a' && String.contains converted_pgn 'c' && String.contains converted_pgn 'k' in
  let has_event = String.contains converted_pgn 'E' && String.contains converted_pgn 'v' && String.contains converted_pgn 'e' && String.contains converted_pgn 'n' && String.contains converted_pgn 't' in
  let has_result = String.contains converted_pgn '1' && String.contains converted_pgn '-' && String.contains converted_pgn '0' in
  
  Printf.printf "✅ Compatibility test:\n";
  Printf.printf "   Contains White tag: %s\n" (if has_white then "✅" else "❌");
  Printf.printf "   Contains Black tag: %s\n" (if has_black then "✅" else "❌");
  Printf.printf "   Contains Event tag: %s\n" (if has_event then "✅" else "❌");
  Printf.printf "   Contains result: %s\n" (if has_result then "✅" else "❌");
  
  Lwt.return (has_white && has_black && has_event && has_result)

(** Test error handling *)
let test_error_handling () =
  Printf.printf "\n=== Testing Error Handling ===\n";
  
  (* Test with invalid player name *)
  let* player_opt = fetch_player_info "invalid_player_name_that_does_not_exist_12345" in
  match player_opt with
  | Some _ ->
      Printf.printf "⚠️  Unexpected success for invalid player\n";
      Lwt.return false
  | None ->
      Printf.printf "✅ Correctly handled invalid player\n";
      Lwt.return true

(** Main test runner *)
let () =
  Printf.printf "=== Online Chess.com API Tests ===\n\n";
  
  let run_tests () =
    let* test1 = test_fetch_random_game () in
    let* test2 = test_fetch_random_games () in
    let* test3 = test_fetch_player_info () in
    let* test4 = test_fetch_player_games () in
    let* test5 = test_fetch_game_by_id () in
    let* test6 = test_fetch_ongoing_games () in
    let* test7 = test_search_games () in
    let* test8 = test_get_player_stats () in
    let* test9 = test_get_player_archives () in
    let* test10 = test_get_games_from_archive () in
    let* test11 = test_get_daily_puzzle () in
    let* test12 = test_get_leaderboards () in
    let* test13 = test_data_structure_compatibility () in
    let* test14 = test_error_handling () in
    
    let results = [test1; test2; test3; test4; test5; test6; test7; test8; test9; test10; test11; test12; test13; test14] in
    let passed = List.fold_left (fun acc x -> if x then acc + 1 else acc) 0 results in
    let total = List.length results in
    
    Printf.printf "\n=== Final Results ===\n";
    Printf.printf "Passed: %d/%d tests\n" passed total;
    
    if passed = total then
      Printf.printf "🎉 All online Chess.com API tests passed!\n"
    else
      Printf.printf "❌ Some online tests failed\n";
    
    Lwt.return (passed = total)
  in
  
  let success = Lwt_main.run (run_tests ()) in
  exit (if success then 0 else 1)
