open Pgn_parser

(** Test handling of unfinished games *)

(** Convert game_result to string *)
let game_result_to_string = function
  | WhiteWin -> "1-0"
  | BlackWin -> "0-1"
  | Draw -> "1/2-1/2"
  | Ongoing -> "*"

(** Test parsing games with no result *)
let test_no_result_games () =
  Printf.printf "=== Testing Unfinished Games ===\n";
  
  let unfinished_pgns = [
    (* Game with no result *)
    "[Event \"Test Game\"]\n[White \"Player1\"]\n[Black \"Player2\"]\n\n1. e4 e5 2. Nf3 Nc6 3. Bb5 a6";
    
    (* Game with ongoing result *)
    "[Event \"Test Game\"]\n[White \"Player1\"]\n[Black \"Player2\"]\n\n1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 *";
    
    (* Game with incomplete moves *)
    "[Event \"Test Game\"]\n[White \"Player1\"]\n[Black \"Player2\"]\n\n1. e4";
    
    (* Game with only one move *)
    "[Event \"Test Game\"]\n[White \"Player1\"]\n[Black \"Player2\"]\n\n1. e4 *";
    
    (* Game with no moves at all *)
    "[Event \"Test Game\"]\n[White \"Player1\"]\n[Black \"Player2\"]\n\n*";
  ] in
  
  let results = List.map (fun pgn ->
    match parse_game pgn with
    | Ok game ->
        Printf.printf "✅ Successfully parsed unfinished game:\n";
        Printf.printf "   White: %s\n" (match game.info.white with Some w -> w.name | None -> "Unknown");
        Printf.printf "   Black: %s\n" (match game.info.black with Some b -> b.name | None -> "Unknown");
        Printf.printf "   Moves: %d\n" (List.length game.moves);
        Printf.printf "   Result: %s\n" (match game.info.result with Some r -> game_result_to_string r | None -> "None");
        true
    | Error e ->
        Printf.printf "❌ Failed to parse unfinished game:\n";
        Printf.printf "   Error: ";
        pp_error Format.std_formatter e;
        Printf.printf "\n";
        false
  ) unfinished_pgns in
  
  let passed = List.fold_left (fun acc x -> if x then acc + 1 else acc) 0 results in
  let total = List.length results in
  
  Printf.printf "\n=== Results ===\n";
  Printf.printf "Passed: %d/%d unfinished game tests\n" passed total;
  
  passed = total

(** Test parsing games with ongoing status *)
let test_ongoing_status_games () =
  Printf.printf "\n=== Testing Ongoing Status Games ===\n";
  
  let ongoing_pgns = [
    (* Game marked as ongoing *)
    "[Event \"Ongoing Game\"]\n[White \"Player1\"]\n[Black \"Player2\"]\n[Result \"*\"]\n\n1. e4 e5 2. Nf3 Nc6";
    
    (* Game with ongoing in event name *)
    "[Event \"Ongoing Tournament Game\"]\n[White \"Player1\"]\n[Black \"Player2\"]\n\n1. e4 e5 *";
    
    (* Game with incomplete notation *)
    "[Event \"Test\"]\n[White \"W\"]\n[Black \"B\"]\n\n1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Bxc6 dxc6 5. O-O";
  ] in
  
  let results = List.map (fun pgn ->
    match parse_game pgn with
    | Ok game ->
        Printf.printf "✅ Successfully parsed ongoing game:\n";
        Printf.printf "   Event: %s\n" (match game.info.event with Some e -> e | None -> "Unknown");
        Printf.printf "   Moves: %d\n" (List.length game.moves);
        Printf.printf "   Result: %s\n" (match game.info.result with Some r -> game_result_to_string r | None -> "None");
        true
    | Error e ->
        Printf.printf "❌ Failed to parse ongoing game:\n";
        Printf.printf "   Error: ";
        pp_error Format.std_formatter e;
        Printf.printf "\n";
        false
  ) ongoing_pgns in
  
  let passed = List.fold_left (fun acc x -> if x then acc + 1 else acc) 0 results in
  let total = List.length results in
  
  Printf.printf "\n=== Results ===\n";
  Printf.printf "Passed: %d/%d ongoing status tests\n" passed total;
  
  passed = total

(** Test board state for unfinished games *)
let test_unfinished_board_state () =
  Printf.printf "\n=== Testing Board State for Unfinished Games ===\n";
  
  let unfinished_pgn = "[Event \"Test\"]\n[White \"W\"]\n[Black \"B\"]\n\n1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Bxc6 dxc6 5. O-O" in
  
  match parse_game unfinished_pgn with
  | Ok game ->
      Printf.printf "✅ Successfully parsed unfinished game for board analysis:\n";
      Printf.printf "   Total moves: %d\n" (List.length game.moves);
      
      (* Check board state after each move *)
      List.iteri (fun i move ->
        let _board_after_white = get_board_after_move game.moves (i + 1) true in
        let _board_after_black = get_board_after_move game.moves (i + 1) false in
        
        Printf.printf "   After move %d: Board state available\n" (i + 1);
        
        (* Check if we have Zobrist hash *)
        match move.zobrist_after_white with
        | Some hash -> Printf.printf "     White hash: %Ld\n" hash
        | None -> Printf.printf "     No white hash\n"
      ) game.moves;
      
      true
  | Error e ->
      Printf.printf "❌ Failed to parse game for board analysis: ";
      pp_error Format.std_formatter e;
      Printf.printf "\n";
      false

(** Test conversion back to PGN for unfinished games *)
let test_unfinished_pgn_conversion () =
  Printf.printf "\n=== Testing PGN Conversion for Unfinished Games ===\n";
  
  let unfinished_pgn = "[Event \"Test\"]\n[White \"W\"]\n[Black \"B\"]\n\n1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Bxc6 dxc6 5. O-O" in
  
  match parse_game unfinished_pgn with
  | Ok game ->
      Printf.printf "✅ Successfully parsed unfinished game:\n";
      
      (* Convert back to PGN *)
      let converted_pgn = to_pgn game in
      Printf.printf "   Converted PGN length: %d chars\n" (String.length converted_pgn);
      
      (* Check if result is preserved *)
      let has_result = String.contains converted_pgn '*' in
      Printf.printf "   Contains result marker: %s\n" (if has_result then "Yes" else "No");
      
      (* Parse the converted PGN again *)
      match parse_game converted_pgn with
      | Ok converted_game ->
          Printf.printf "   Successfully re-parsed converted PGN\n";
          Printf.printf "   Moves count: %d (original: %d)\n" (List.length converted_game.moves) (List.length game.moves);
          true
      | Error _ ->
          Printf.printf "   ❌ Failed to re-parse converted PGN\n";
          false
  | Error e ->
      Printf.printf "❌ Failed to parse original game: ";
      pp_error Format.std_formatter e;
      Printf.printf "\n";
      false

(** Main test runner *)
let () =
  Printf.printf "🎯 Unfinished Games Tests\n";
  Printf.printf "========================\n\n";
  
  let test1 = test_no_result_games () in
  let test2 = test_ongoing_status_games () in
  let test3 = test_unfinished_board_state () in
  let test4 = test_unfinished_pgn_conversion () in
  
  let results = [test1; test2; test3; test4] in
  let passed = List.fold_left (fun acc x -> if x then acc + 1 else acc) 0 results in
  let total = List.length results in
  
  Printf.printf "\n=== Final Results ===\n";
  Printf.printf "Passed: %d/%d unfinished games tests\n" passed total;
  
  if passed = total then
    Printf.printf "🎉 All unfinished games tests passed!\n"
  else
    Printf.printf "❌ Some unfinished games tests failed\n";
  
  exit (if passed = total then 0 else 1)
