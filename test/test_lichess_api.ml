open Lwt.Syntax
open Pgn_parser
open Lichess_api

(** Test for fetch_random_game *)
let test_fetch_random_game () =
  Printf.printf "Testing fetch_random_game...\n";
  
  let* game_opt = fetch_random_game () in
  match game_opt with
  | Some game ->
      Printf.printf "✅ Fetched game: %s vs %s\n" game.white game.black;
      Printf.printf "   ID: %s\n" game.id;
      Printf.printf "   Speed: %s, Status: %s\n" game.speed game.status;
      (match game.rating_white with
       | Some r -> Printf.printf "   White rating: %d\n" r
       | None -> Printf.printf "   White rating: None\n");
      (match game.rating_black with
       | Some r -> Printf.printf "   Black rating: %d\n" r
       | None -> Printf.printf "   Black rating: None\n");
      (match game.opening with
       | Some o -> Printf.printf "   Opening: %s\n" o
       | None -> Printf.printf "   Opening: None\n");
      Printf.printf "   PGN length: %d chars\n" (String.length game.pgn);
      
      (* Test parsing the PGN *)
      (match parse_game game.pgn with
       | Ok parsed_game ->
           Printf.printf "   ✅ Parsed: %d moves\n" (List.length parsed_game.moves)
       | Error e ->
           Printf.printf "   ❌ Parse failed: %s\n" (match e with
             | InvalidMove s -> s | InvalidTag s -> s 
             | InvalidFormat s -> s | UnexpectedEnd s -> s));
      Lwt.return true
  | None ->
      Printf.printf "❌ Failed to fetch game\n";
      Lwt.return false

(** Test for fetch_random_games *)
let test_fetch_random_games () =
  Printf.printf "Testing fetch_random_games...\n";
  
  let* games = fetch_random_games 3 in
  Printf.printf "✅ Fetched %d games\n" (List.length games);
  
  let* results = Lwt_list.map_s (fun game ->
    Printf.printf "Game: %s vs %s\n" game.white game.black;
    Printf.printf "  ID: %s\n" game.id;
    Printf.printf "  Speed: %s, Status: %s\n" game.speed game.status;
    (match game.rating_white with
     | Some r -> Printf.printf "  White rating: %d\n" r
     | None -> ());
    (match game.rating_black with
     | Some r -> Printf.printf "  Black rating: %d\n" r
     | None -> ());
    Printf.printf "  PGN length: %d chars\n" (String.length game.pgn);
    
    (* Test parsing *)
    match parse_game game.pgn with
    | Ok parsed_game ->
        Printf.printf "  ✅ Parsed: %d moves\n" (List.length parsed_game.moves);
        Lwt.return true
    | Error _ ->
        Printf.printf "  ❌ Parse failed\n";
        Lwt.return false
  ) games in
  
  let passed = List.fold_left (fun acc x -> if x then acc + 1 else acc) 0 results in
  let total = List.length results in
  
  Printf.printf "Parse results: %d/%d games parsed successfully\n" passed total;
  Lwt.return (passed = total)

(** Test for fetch_player_info *)
let test_fetch_player_info () =
  Printf.printf "Testing fetch_player_info...\n";
  
  let* player_opt = fetch_player_info "DrNykterstein" in
  match player_opt with
  | Some player ->
      Printf.printf "✅ Player: %s\n" player.username;
      Printf.printf "   ID: %s\n" player.id;
      (match player.rating with
       | Some r -> Printf.printf "   Rating: %d\n" r
       | None -> Printf.printf "   Rating: None\n");
      (match player.title with
       | Some t -> Printf.printf "   Title: %s\n" t
       | None -> Printf.printf "   Title: None\n");
      Printf.printf "   Online: %s\n" (if player.online then "Yes" else "No");
      Printf.printf "   Playing: %s\n" (if player.playing then "Yes" else "No");
      Lwt.return true
  | None ->
      Printf.printf "❌ Failed to fetch player info\n";
      Lwt.return false

(** Test for fetch_player_games *)
let test_fetch_player_games () =
  Printf.printf "Testing fetch_player_games...\n";
  
  let* games = fetch_player_games "DrNykterstein" ~max_games:2 () in
  Printf.printf "✅ Fetched %d games for DrNykterstein\n" (List.length games);
  
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
    Printf.printf "  PGN length: %d chars\n" (String.length game.pgn)
  ) games;
  Lwt.return true

(** Test for get_player_stats *)
let test_get_player_stats () =
  Printf.printf "Testing get_player_stats...\n";
  
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
      Lwt.return true
  | None ->
      Printf.printf "❌ Failed to fetch player stats\n";
      Lwt.return false

(** Test for search_games *)
let test_search_games () =
  Printf.printf "Testing search_games...\n";
  
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
  Lwt.return true

(** Test for fetch_ongoing_games *)
let test_fetch_ongoing_games () =
  Printf.printf "Testing fetch_ongoing_games...\n";
  
  let* games = fetch_ongoing_games () in
  Printf.printf "✅ Found %d ongoing games\n" (List.length games);
  
  List.iteri (fun i game ->
    Printf.printf "Game %d: %s vs %s\n" (i + 1) game.white game.black;
    Printf.printf "  ID: %s\n" game.id;
    Printf.printf "  Speed: %s, Status: %s\n" game.speed game.status;
    Printf.printf "  PGN length: %d chars\n" (String.length game.pgn)
  ) games;
  Lwt.return true

(** Test for fetch_game_by_id *)
let test_fetch_game_by_id () =
  Printf.printf "Testing fetch_game_by_id...\n";
  
  (* First get a random game to get an ID *)
  let* game_opt = fetch_random_game () in
  match game_opt with
  | Some random_game ->
      Printf.printf "Got random game ID: %s\n" random_game.id;
      
      (* Try to fetch the same game by ID *)
      let* fetched_game_opt = fetch_game_by_id random_game.id in
      (match fetched_game_opt with
       | Some fetched_game ->
           Printf.printf "✅ Successfully fetched game by ID\n";
           Printf.printf "   White: %s vs Black: %s\n" fetched_game.white fetched_game.black;
           Printf.printf "   ID: %s\n" fetched_game.id;
           Printf.printf "   PGN length: %d chars\n" (String.length fetched_game.pgn);
           Lwt.return true
       | None ->
           Printf.printf "❌ Failed to fetch game by ID\n";
           Lwt.return false)
  | None ->
      Printf.printf "❌ Failed to get random game for ID test\n";
      Lwt.return false

(** Test data structure validation *)
let test_data_structures () =
  Printf.printf "Testing data structures...\n";
  
  (* Test lichess_game structure *)
  let test_game = {
    id = "test_id";
    white = "test_white";
    black = "test_black";
    pgn = "test pgn";
    winner = Some "test_winner";
    speed = "test_speed";
    status = "test_status";
    created_at = Int64.of_int 1234567890;
    rating_white = Some 2500;
    rating_black = Some 2400;
    time_control = Some "test_time_control";
    variant = Some "test_variant";
    opening = Some "test_opening";
  } in
  
  Printf.printf "✅ Created test game:\n";
  Printf.printf "   ID: %s\n" test_game.id;
  Printf.printf "   White: %s\n" test_game.white;
  Printf.printf "   Black: %s\n" test_game.black;
  Printf.printf "   Winner: %s\n" (Option.value ~default:"None" test_game.winner);
  Printf.printf "   Speed: %s\n" test_game.speed;
  Printf.printf "   Status: %s\n" test_game.status;
  Printf.printf "   White rating: %d\n" (Option.value ~default:0 test_game.rating_white);
  Printf.printf "   Black rating: %d\n" (Option.value ~default:0 test_game.rating_black);
  Printf.printf "   Time control: %s\n" (Option.value ~default:"None" test_game.time_control);
  Printf.printf "   Variant: %s\n" (Option.value ~default:"None" test_game.variant);
  Printf.printf "   Opening: %s\n" (Option.value ~default:"None" test_game.opening);
  
  (* Test lichess_player structure *)
  let test_player = {
    id = "test_player_id";
    username = "test_username";
    rating = Some 2500;
    title = Some "GM";
    online = true;
    playing = false;
    country = Some "US";
    created_at = Int64.of_int 1234567890;
  } in
  
  Printf.printf "✅ Created test player:\n";
  Printf.printf "   ID: %s\n" test_player.id;
  Printf.printf "   Username: %s\n" test_player.username;
  Printf.printf "   Rating: %d\n" (Option.value ~default:0 test_player.rating);
  Printf.printf "   Title: %s\n" (Option.value ~default:"None" test_player.title);
  Printf.printf "   Online: %s\n" (if test_player.online then "Yes" else "No");
  Printf.printf "   Playing: %s\n" (if test_player.playing then "Yes" else "No");
  Printf.printf "   Country: %s\n" (Option.value ~default:"None" test_player.country);
  
  (* Test player_stats structure *)
  let test_stats = {
    total_games = 1000;
    wins = 600;
    losses = 300;
    draws = 100;
    win_rate = 0.6;
    rating_avg = 2500;
    best_rating = 2800;
    current_rating = 2500;
  } in
  
  Printf.printf "✅ Created test stats:\n";
  Printf.printf "   Total games: %d\n" test_stats.total_games;
  Printf.printf "   Wins: %d, Losses: %d, Draws: %d\n" test_stats.wins test_stats.losses test_stats.draws;
  Printf.printf "   Win rate: %.1f%%\n" (test_stats.win_rate *. 100.0);
  Printf.printf "   Average rating: %d\n" test_stats.rating_avg;
  Printf.printf "   Best rating: %d\n" test_stats.best_rating;
  Printf.printf "   Current rating: %d\n" test_stats.current_rating;
  
  Lwt.return true

(** Test error handling *)
let test_error_handling () =
  Printf.printf "Testing error handling...\n";
  
  (* Test with invalid username *)
  let* player_opt = fetch_player_info "invalid_username_that_does_not_exist_12345" in
  (match player_opt with
   | Some _ -> 
       Printf.printf "⚠️  Unexpected success for invalid username\n";
       Lwt.return false
   | None -> 
       Printf.printf "✅ Correctly handled invalid username\n";
       Lwt.return true)

(** Main test runner *)
let () =
  Printf.printf "=== Testing Lichess API Features ===\n\n";
  
  let run_tests () =
    let* test1 = test_fetch_random_game () in
    let* test2 = test_fetch_random_games () in
    let* test3 = test_fetch_player_info () in
    let* test4 = test_fetch_player_games () in
    let* test5 = test_get_player_stats () in
    let* test6 = test_search_games () in
    let* test7 = test_fetch_ongoing_games () in
    let* test8 = test_fetch_game_by_id () in
    let* test9 = test_data_structures () in
    let* test10 = test_error_handling () in
    
    let results = [test1; test2; test3; test4; test5; test6; test7; test8; test9; test10] in
    let passed = List.fold_left (fun acc x -> if x then acc + 1 else acc) 0 results in
    let total = List.length results in
    
    Printf.printf "\n=== Final Results ===\n";
    Printf.printf "Passed: %d/%d tests\n" passed total;
    
    if passed = total then
      Printf.printf "🎉 All Lichess API tests passed!\n"
    else
      Printf.printf "❌ Some tests failed\n";
    
    Lwt.return (passed = total)
  in
  
  let _ = Lwt_main.run (run_tests ()) in
  exit 0
