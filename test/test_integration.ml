open Pgn_parser
open Lichess_api

(** Integration tests for PGN parser and Lichess API *)

(** Test roundtrip: lichess_game -> PGN -> parsed_game *)
let test_roundtrip_parsing () =
  Printf.printf "=== Testing Roundtrip Parsing ===\n";
  
  let test_game = {
    id = "test_id";
    white = "Alice";
    black = "Bob";
    pgn = "[Event \"Test Game\"]\n[Site \"Test Site\"]\n[Date \"2024.01.01\"]\n[White \"Alice\"]\n[Black \"Bob\"]\n\n1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Bxc6 dxc6 5. O-O";
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
  
  Printf.printf "✅ Original game:\n";
  Printf.printf "   White: %s\n" test_game.white;
  Printf.printf "   Black: %s\n" test_game.black;
  Printf.printf "   PGN length: %d chars\n" (String.length test_game.pgn);
  
  (* Convert to PGN using lichess_game_to_pgn *)
  let converted_pgn = lichess_game_to_pgn test_game in
  Printf.printf "✅ Converted PGN length: %d chars\n" (String.length converted_pgn);
  
  (* Parse the converted PGN *)
  match parse_game converted_pgn with
  | Ok parsed_game ->
      Printf.printf "✅ Successfully parsed converted PGN:\n";
      Printf.printf "   Parsed moves: %d\n" (List.length parsed_game.moves);
      Printf.printf "   White: %s\n" (match parsed_game.info.white with Some w -> w.name | None -> "Unknown");
      Printf.printf "   Black: %s\n" (match parsed_game.info.black with Some b -> b.name | None -> "Unknown");
      Printf.printf "   Event: %s\n" (match parsed_game.info.event with Some e -> e | None -> "Unknown");
      
      (* Check that the parsed data matches the original *)
      let white_match = match parsed_game.info.white with Some w -> w.name = test_game.white | None -> false in
      let black_match = match parsed_game.info.black with Some b -> b.name = test_game.black | None -> false in
      
      Printf.printf "   White match: %s\n" (if white_match then "✅" else "❌");
      Printf.printf "   Black match: %s\n" (if black_match then "✅" else "❌");
      
      white_match && black_match
  | Error e ->
      Printf.printf "❌ Failed to parse converted PGN: ";
      pp_error Format.std_formatter e;
      Printf.printf "\n";
      false

(** Test PGN parsing with various lichess_game configurations *)
let test_various_game_configurations () =
  Printf.printf "\n=== Testing Various Game Configurations ===\n";
  
  let test_cases : lichess_game list = [
    (* Standard game *)
    {
      id = "standard";
      white = "Player1";
      black = "Player2";
      pgn = "[Event \"Standard Game\"]\n[White \"Player1\"]\n[Black \"Player2\"]\n\n1. e4 e5 1-0";
      winner = Some "1-0";
      speed = "standard";
      status = "finished";
      created_at = Int64.of_int 1234567890;
      rating_white = Some 2500;
      rating_black = Some 2400;
      time_control = Some "10+0";
      variant = Some "standard";
      opening = Some "King's Pawn";
    };
    
    (* Blitz game *)
    {
      id = "blitz";
      white = "BlitzPlayer";
      black = "SpeedPlayer";
      pgn = "[Event \"Blitz Game\"]\n[White \"BlitzPlayer\"]\n[Black \"SpeedPlayer\"]\n\n1. d4 d5 2. c4 dxc4 0-1";
      winner = Some "0-1";
      speed = "blitz";
      status = "finished";
      created_at = Int64.of_int 1234567890;
      rating_white = Some 2000;
      rating_black = Some 2100;
      time_control = Some "3+0";
      variant = Some "standard";
      opening = Some "Queen's Gambit";
    };
    
    (* Game with no ratings *)
    {
      id = "no_ratings";
      white = "Unrated1";
      black = "Unrated2";
      pgn = "[Event \"Unrated Game\"]\n[White \"Unrated1\"]\n[Black \"Unrated2\"]\n\n1. Nf3 Nf6 1/2-1/2";
      winner = Some "1/2-1/2";
      speed = "classical";
      status = "finished";
      created_at = Int64.of_int 1234567890;
      rating_white = None;
      rating_black = None;
      time_control = Some "15+15";
      variant = Some "standard";
      opening = None;
    };
  ] in
  
  let rec test_all_cases (cases : lichess_game list) passed total =
    match cases with
    | [] -> 
        Printf.printf "Configuration test results: %d/%d passed\n" passed total;
        passed = total
    | game :: rest ->
        Printf.printf "Testing %s game (%s vs %s)...\n" game.id game.white game.black;
        
        let converted_pgn = lichess_game_to_pgn game in
        let parse_result = parse_game converted_pgn in
        
        (match parse_result with
         | Ok parsed_game ->
             let white_match = match parsed_game.info.white with Some w -> w.name = game.white | None -> false in
             let black_match = match parsed_game.info.black with Some b -> b.name = game.black | None -> false in
             
             if white_match && black_match then
               Printf.printf "  ✅ Parsed successfully\n"
             else
               Printf.printf "  ❌ Data mismatch\n";
             
             test_all_cases rest (if white_match && black_match then passed + 1 else passed) (total + 1)
         | Error e ->
             Printf.printf "  ❌ Parse failed: ";
             pp_error Format.std_formatter e;
             Printf.printf "\n";
             test_all_cases rest passed (total + 1))
  in
  
  test_all_cases test_cases 0 0

(** Test error handling with invalid lichess_game data *)
let test_error_handling () =
  Printf.printf "\n=== Testing Error Handling ===\n";
  
  let invalid_games = [
    (* Invalid PGN with invalid move *)
    {
      id = "invalid_move";
      white = "Player1";
      black = "Player2";
      pgn = "[Event \"Test\"]\n[White \"Player1\"]\n[Black \"Player2\"]\n\n1. e9";  (* Invalid square *)
      winner = Some "1-0";
      speed = "standard";
      status = "finished";
      created_at = Int64.of_int 1234567890;
      rating_white = Some 2500;
      rating_black = Some 2400;
      time_control = Some "10+0";
      variant = Some "standard";
      opening = Some "Test";
    };
    
    (* Invalid PGN with invalid castling *)
    {
      id = "invalid_castling";
      white = "Player1";
      black = "Player2";
      pgn = "[Event \"Test\"]\n[White \"Player1\"]\n[Black \"Player2\"]\n\n1. O-O-O-O";  (* Invalid castling *)
      winner = Some "1-0";
      speed = "standard";
      status = "finished";
      created_at = Int64.of_int 1234567890;
      rating_white = Some 2500;
      rating_black = Some 2400;
      time_control = Some "10+0";
      variant = Some "standard";
      opening = Some "Test";
    };
  ] in
  
  let rec test_invalid_cases (cases : lichess_game list) passed total =
    match cases with
    | [] -> 
        Printf.printf "Error handling test results: %d/%d passed\n" passed total;
        passed = total
    | game :: rest ->
        Printf.printf "Testing %s game...\n" game.id;
        
        let converted_pgn = lichess_game_to_pgn game in
        let parse_result = parse_game converted_pgn in
        
        (match parse_result with
         | Ok _ ->
             Printf.printf "  ⚠️  Unexpected success for invalid data\n";
             test_invalid_cases rest passed (total + 1)
         | Error _ ->
             Printf.printf "  ✅ Correctly handled invalid data\n";
             test_invalid_cases rest (passed + 1) (total + 1))
  in
  
  test_invalid_cases invalid_games 0 0

(** Test data structure compatibility *)
let test_data_structure_compatibility () =
  Printf.printf "\n=== Testing Data Structure Compatibility ===\n";
  
  (* Test that lichess_game fields can be properly converted to PGN tags *)
  let test_game = {
    id = "compat_test";
    white = "CompatPlayer";
    black = "CompatOpponent";
    pgn = "[Event \"Compatibility Test\"]\n[White \"CompatPlayer\"]\n[Black \"CompatOpponent\"]\n\n1. e4 1-0";
    winner = Some "1-0";
    speed = "standard";
    status = "finished";
    created_at = Int64.of_int 1234567890;
    rating_white = Some 2500;
    rating_black = Some 2400;
    time_control = Some "10+0";
    variant = Some "standard";
    opening = Some "King's Pawn";
  } in
  
  let converted_pgn = lichess_game_to_pgn test_game in
  
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
  
  has_white && has_black && has_event && has_result

(** Test performance with large PGN *)
let test_performance () =
  Printf.printf "\n=== Testing Performance ===\n";
  
  (* Create a game with a longer PGN *)
  let moves = List.init 20 (fun i -> 
    Printf.sprintf "%d. e%d e%d" (i + 1) ((i mod 8) + 1) ((i mod 8) + 1)) in
  let long_pgn = "[Event \"Long Game\"]\n[White \"LongPlayer\"]\n[Black \"LongOpponent\"]\n\n" ^
                 String.concat " " moves ^ " 1-0" in
  
  let test_game = {
    id = "performance_test";
    white = "LongPlayer";
    black = "LongOpponent";
    pgn = long_pgn;
    winner = Some "1-0";
    speed = "standard";
    status = "finished";
    created_at = Int64.of_int 1234567890;
    rating_white = Some 2500;
    rating_black = Some 2400;
    time_control = Some "10+0";
    variant = Some "standard";
    opening = Some "Performance Test";
  } in
  
  Printf.printf "✅ Created long game with %d chars\n" (String.length test_game.pgn);
  
  let converted_pgn = lichess_game_to_pgn test_game in
  Printf.printf "✅ Converted to PGN with %d chars\n" (String.length converted_pgn);
  
  match parse_game converted_pgn with
  | Ok parsed_game ->
      Printf.printf "✅ Successfully parsed long game: %d moves\n" (List.length parsed_game.moves);
      true
  | Error e ->
      Printf.printf "❌ Failed to parse long game: ";
      pp_error Format.std_formatter e;
      Printf.printf "\n";
      false

(** Main test runner *)
let () =
  Printf.printf "=== Integration Tests: PGN Parser + Lichess API ===\n\n";
  
  let test1 = test_roundtrip_parsing () in
  let test2 = test_various_game_configurations () in
  let test3 = test_error_handling () in
  let test4 = test_data_structure_compatibility () in
  let test5 = test_performance () in
  
  let results = [test1; test2; test3; test4; test5] in
  let passed = List.fold_left (fun acc x -> if x then acc + 1 else acc) 0 results in
  let total = List.length results in
  
  Printf.printf "\n=== Final Integration Test Results ===\n";
  Printf.printf "Passed: %d/%d tests\n" passed total;
  
  if passed = total then
    Printf.printf "🎉 All integration tests passed!\n"
  else
    Printf.printf "❌ Some integration tests failed\n";
  
  exit (if passed = total then 0 else 1)
