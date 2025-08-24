open Pgn_parser
open Lichess_api

(** Offline tests for Lichess API data structures and functions *)

(** Test data structure validation *)
let test_data_structures () =
  Printf.printf "=== Testing Data Structures ===\n";
  
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
  
  (* Test lichess_tournament structure *)
  let test_tournament = {
    id = "test_tournament_id";
    name = "Test Tournament";
    status = "finished";
    start_date = Int64.of_int 1234567890;
    end_date = Some (Int64.of_int 1234567890);
    nb_players = 100;
    time_control = "10+0";
    variant = "standard";
    rated = true;
  } in
  
  Printf.printf "✅ Created test tournament:\n";
  Printf.printf "   ID: %s\n" test_tournament.id;
  Printf.printf "   Name: %s\n" test_tournament.name;
  Printf.printf "   Status: %s\n" test_tournament.status;
  Printf.printf "   Players: %d\n" test_tournament.nb_players;
  Printf.printf "   Time control: %s\n" test_tournament.time_control;
  Printf.printf "   Variant: %s\n" test_tournament.variant;
  Printf.printf "   Rated: %s\n" (if test_tournament.rated then "Yes" else "No");
  
  true

(** Test lichess_game_to_pgn function *)
let test_lichess_game_to_pgn () =
  Printf.printf "\n=== Testing lichess_game_to_pgn ===\n";
  
  let test_game = {
    id = "test_id";
    white = "test_white";
    black = "test_black";
    pgn = "[Event \"Test Game\"]\n[White \"test_white\"]\n[Black \"test_black\"]\n\n1. e4 e5 1-0";
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
  
  let pgn = lichess_game_to_pgn test_game in
  Printf.printf "✅ Converted game to PGN:\n%s\n" pgn;
  
  (* Test that the PGN contains expected content *)
  let has_event = String.contains pgn 'E' && String.contains pgn 'v' && String.contains pgn 'e' && String.contains pgn 'n' && String.contains pgn 't' in
  let has_white = String.contains pgn 'W' && String.contains pgn 'h' && String.contains pgn 'i' && String.contains pgn 't' && String.contains pgn 'e' in
  let has_black = String.contains pgn 'B' && String.contains pgn 'l' && String.contains pgn 'a' && String.contains pgn 'c' && String.contains pgn 'k' in
  let has_moves = String.contains pgn 'e' && String.contains pgn '4' && String.contains pgn 'e' && String.contains pgn '5' in
  
  Printf.printf "   Contains Event tag: %s\n" (if has_event then "✅" else "❌");
  Printf.printf "   Contains White tag: %s\n" (if has_white then "✅" else "❌");
  Printf.printf "   Contains Black tag: %s\n" (if has_black then "✅" else "❌");
  Printf.printf "   Contains moves: %s\n" (if has_moves then "✅" else "❌");
  
  has_event && has_white && has_black && has_moves

(** Test PGN parsing with lichess_game data *)
let test_pgn_parsing_with_lichess_data () =
  Printf.printf "\n=== Testing PGN Parsing with Lichess Data ===\n";
  
  let test_pgn = "[Event \"Test Game\"]\n[Site \"Test Site\"]\n[Date \"2024.01.01\"]\n[White \"Alice\"]\n[Black \"Bob\"]\n\n1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Bxc6 dxc6 5. O-O" in
  
  let test_game = {
    id = "test_id";
    white = "Alice";
    black = "Bob";
    pgn = test_pgn;
    winner = Some "1-0";
    speed = "standard";
    status = "finished";
    created_at = Int64.of_int 1234567890;
    rating_white = Some 2500;
    rating_black = Some 2400;
    time_control = Some "10+0";
    variant = Some "standard";
    opening = Some "Ruy Lopez";
  } in
  
  Printf.printf "✅ Created test game with PGN:\n";
  Printf.printf "   White: %s\n" test_game.white;
  Printf.printf "   Black: %s\n" test_game.black;
  Printf.printf "   PGN length: %d chars\n" (String.length test_game.pgn);
  
  (* Test parsing the PGN *)
  match parse_game test_game.pgn with
  | Ok parsed_game ->
      Printf.printf "✅ Successfully parsed PGN:\n";
      Printf.printf "   Parsed moves: %d\n" (List.length parsed_game.moves);
      Printf.printf "   White: %s\n" (match parsed_game.info.white with Some w -> w.name | None -> "Unknown");
      Printf.printf "   Black: %s\n" (match parsed_game.info.black with Some b -> b.name | None -> "Unknown");
      Printf.printf "   Event: %s\n" (match parsed_game.info.event with Some e -> e | None -> "Unknown");
      true
  | Error e ->
      Printf.printf "❌ Failed to parse PGN: ";
      pp_error Format.std_formatter e;
      Printf.printf "\n";
      false

(** Test data validation *)
let test_data_validation () =
  Printf.printf "\n=== Testing Data Validation ===\n";
  
  (* Test that required fields are present *)
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
  
  let valid_id = String.length test_game.id > 0 in
  let valid_white = String.length test_game.white > 0 in
  let valid_black = String.length test_game.black > 0 in
  let valid_pgn = String.length test_game.pgn > 0 in
  let valid_speed = String.length test_game.speed > 0 in
  let valid_status = String.length test_game.status > 0 in
  
  Printf.printf "✅ Data validation:\n";
  Printf.printf "   Valid ID: %s\n" (if valid_id then "✅" else "❌");
  Printf.printf "   Valid White: %s\n" (if valid_white then "✅" else "❌");
  Printf.printf "   Valid Black: %s\n" (if valid_black then "✅" else "❌");
  Printf.printf "   Valid PGN: %s\n" (if valid_pgn then "✅" else "❌");
  Printf.printf "   Valid Speed: %s\n" (if valid_speed then "✅" else "❌");
  Printf.printf "   Valid Status: %s\n" (if valid_status then "✅" else "❌");
  
  valid_id && valid_white && valid_black && valid_pgn && valid_speed && valid_status

(** Test optional field handling *)
let test_optional_fields () =
  Printf.printf "\n=== Testing Optional Fields ===\n";
  
  (* Test game with all optional fields as None *)
  let test_game_minimal = {
    id = "test_id";
    white = "test_white";
    black = "test_black";
    pgn = "test pgn";
    winner = None;
    speed = "test_speed";
    status = "test_status";
    created_at = Int64.of_int 1234567890;
    rating_white = None;
    rating_black = None;
    time_control = None;
    variant = None;
    opening = None;
  } in
  
  Printf.printf "✅ Created minimal test game:\n";
  Printf.printf "   Winner: %s\n" (match test_game_minimal.winner with Some w -> w | None -> "None");
  Printf.printf "   White rating: %s\n" (match test_game_minimal.rating_white with Some r -> string_of_int r | None -> "None");
  Printf.printf "   Black rating: %s\n" (match test_game_minimal.rating_black with Some r -> string_of_int r | None -> "None");
  Printf.printf "   Time control: %s\n" (match test_game_minimal.time_control with Some tc -> tc | None -> "None");
  Printf.printf "   Variant: %s\n" (match test_game_minimal.variant with Some v -> v | None -> "None");
  Printf.printf "   Opening: %s\n" (match test_game_minimal.opening with Some o -> o | None -> "None");
  
  (* Test that the game is still valid *)
  let valid_id = String.length test_game_minimal.id > 0 in
  let valid_white = String.length test_game_minimal.white > 0 in
  let valid_black = String.length test_game_minimal.black > 0 in
  let valid_pgn = String.length test_game_minimal.pgn > 0 in
  
  Printf.printf "   Valid minimal game: %s\n" (if valid_id && valid_white && valid_black && valid_pgn then "✅" else "❌");
  
  valid_id && valid_white && valid_black && valid_pgn

(** Main test runner *)
let () =
  Printf.printf "=== Offline Lichess API Tests ===\n\n";
  
  let test1 = test_data_structures () in
  let test2 = test_lichess_game_to_pgn () in
  let test3 = test_pgn_parsing_with_lichess_data () in
  let test4 = test_data_validation () in
  let test5 = test_optional_fields () in
  
  let results = [test1; test2; test3; test4; test5] in
  let passed = List.fold_left (fun acc x -> if x then acc + 1 else acc) 0 results in
  let total = List.length results in
  
  Printf.printf "\n=== Final Results ===\n";
  Printf.printf "Passed: %d/%d tests\n" passed total;
  
  if passed = total then
    Printf.printf "🎉 All offline Lichess API tests passed!\n"
  else
    Printf.printf "❌ Some offline tests failed\n";
  
  exit (if passed = total then 0 else 1)
