open Pgn_parser

(** Test advanced move parsing capabilities *)

(** Test disambiguation moves *)
let test_disambiguation_moves () =
  Printf.printf "=== Testing Disambiguation Moves ===\n";
  
  let test_cases = [
    (* File disambiguation *)
    ("Rae1", "Rook from a-file to e1");
    ("Rhe1", "Rook from h-file to e1");
    ("Nce4", "Knight from c-file to e4");
    
    (* Rank disambiguation *)
    ("R1e1", "Rook from rank 1 to e1");
    ("R8e1", "Rook from rank 8 to e1");
    ("N3e4", "Knight from rank 3 to e4");
    
    (* Full disambiguation *)
    ("Ra1e1", "Rook from a1 to e1");
    ("Rh8e1", "Rook from h8 to e1");
    ("Nc3e4", "Knight from c3 to e4");
    
    (* Complex captures with disambiguation *)
    ("Raxe1", "Rook from a-file captures on e1");
    ("N3xe4", "Knight from rank 3 captures on e4");
    ("Ra1xe1", "Rook from a1 captures on e1");
  ] in
  
  let results = List.map (fun (move_str, description) ->
    match parse_simple_move move_str with
    | Ok _move ->
        Printf.printf "✅ %s: %s\n" description move_str;
        true
    | Error e ->
        Printf.printf "❌ %s: %s - Error: " description move_str;
        pp_error Format.std_formatter e;
        Printf.printf "\n";
        false
  ) test_cases in
  
  let passed = List.fold_left (fun acc x -> if x then acc + 1 else acc) 0 results in
  let total = List.length results in
  
  Printf.printf "\n=== Results ===\n";
  Printf.printf "Passed: %d/%d disambiguation tests\n" passed total;
  
  passed = total

(** Test complex captures and promotions *)
let test_complex_captures () =
  Printf.printf "\n=== Testing Complex Captures ===\n";
  
  let test_cases = [
    (* Captures with promotion *)
    ("exd8=Q+", "Pawn captures and promotes to Queen with check");
    ("exd8=Q#", "Pawn captures and promotes to Queen with checkmate");
    ("gxf8=Q", "Pawn captures and promotes to Queen");
    
    (* Captures with disambiguation *)
    ("Raxe1", "Rook from a-file captures on e1");
    ("N3xe4", "Knight from rank 3 captures on e4");
    ("Bxe4", "Bishop captures on e4");
    
    (* Complex captures *)
    ("Qxf7+", "Queen captures on f7 with check");
    ("Bxf7#", "Bishop captures on f7 with checkmate");
  ] in
  
  let results = List.map (fun (move_str, description) ->
    match parse_simple_move move_str with
    | Ok _move ->
        Printf.printf "✅ %s: %s\n" description move_str;
        true
    | Error e ->
        Printf.printf "❌ %s: %s - Error: " description move_str;
        pp_error Format.std_formatter e;
        Printf.printf "\n";
        false
  ) test_cases in
  
  let passed = List.fold_left (fun acc x -> if x then acc + 1 else acc) 0 results in
  let total = List.length results in
  
  Printf.printf "\n=== Results ===\n";
  Printf.printf "Passed: %d/%d complex capture tests\n" passed total;
  
  passed = total

(** Test en passant moves *)
let test_en_passant_moves () =
  Printf.printf "\n=== Testing En Passant Moves ===\n";
  
  let test_cases = [
    ("exd6", "Pawn captures en passant on d6");
    ("exd6e.p.", "Pawn captures en passant on d6 (explicit)");
    ("exd6ep", "Pawn captures en passant on d6 (short)");
  ] in
  
  let results = List.map (fun (move_str, description) ->
    match parse_simple_move move_str with
    | Ok _move ->
        Printf.printf "✅ %s: %s\n" description move_str;
        true
    | Error e ->
        Printf.printf "❌ %s: %s - Error: " description move_str;
        pp_error Format.std_formatter e;
        Printf.printf "\n";
        false
  ) test_cases in
  
  let passed = List.fold_left (fun acc x -> if x then acc + 1 else acc) 0 results in
  let total = List.length results in
  
  Printf.printf "\n=== Results ===\n";
  Printf.printf "Passed: %d/%d en passant tests\n" passed total;
  
  passed = total

(** Test promotion moves *)
let test_promotion_moves () =
  Printf.printf "\n=== Testing Promotion Moves ===\n";
  
  let test_cases = [
    ("e8=Q", "Pawn promotes to Queen");
    ("e8=Q+", "Pawn promotes to Queen with check");
    ("e8=Q#", "Pawn promotes to Queen with checkmate");
    ("e8=R", "Pawn promotes to Rook");
    ("e8=B", "Pawn promotes to Bishop");
    ("e8=N", "Pawn promotes to Knight");
  ] in
  
  let results = List.map (fun (move_str, description) ->
    match parse_simple_move move_str with
    | Ok _move ->
        Printf.printf "✅ %s: %s\n" description move_str;
        true
    | Error e ->
        Printf.printf "❌ %s: %s - Error: " description move_str;
        pp_error Format.std_formatter e;
        Printf.printf "\n";
        false
  ) test_cases in
  
  let passed = List.fold_left (fun acc x -> if x then acc + 1 else acc) 0 results in
  let total = List.length results in
  
  Printf.printf "\n=== Results ===\n";
  Printf.printf "Passed: %d/%d promotion tests\n" passed total;
  
  passed = total

(** Test invalid moves *)
let test_invalid_moves () =
  Printf.printf "\n=== Testing Invalid Moves ===\n";
  
  let test_cases = [
    ("", "Empty move");
    ("X", "Invalid piece");
    ("Z", "Invalid piece");
    ("i1", "Invalid file");
    ("a9", "Invalid rank");
    ("a0", "Invalid rank");
    ("K", "Incomplete move");
    ("Q", "Incomplete move");
    ("N", "Incomplete move");
    ("B", "Incomplete move");
    ("R", "Incomplete move");
    ("P", "Invalid piece (P is not used in PGN)");
    ("O-O-O-O", "Invalid castling");
    ("0-0-0-0", "Invalid castling");
    ("O-O-O-O+", "Invalid castling with check");
    ("e8=P", "Invalid promotion piece");
    ("e8=K", "Invalid promotion piece");
  ] in
  
  let results = List.map (fun (move_str, description) ->
    match parse_simple_move move_str with
    | Ok _move ->
        Printf.printf "⚠️  %s: %s (unexpectedly succeeded)\n" description move_str;
        false
    | Error _e ->
        Printf.printf "✅ %s: %s (correctly failed)\n" description move_str;
        true
  ) test_cases in
  
  let passed = List.fold_left (fun acc x -> if x then acc + 1 else acc) 0 results in
  let total = List.length results in
  
  Printf.printf "\n=== Results ===\n";
  Printf.printf "Passed: %d/%d invalid move tests\n" passed total;
  
  passed = total

(** Test simple game with advanced moves *)
let test_simple_game () =
  Printf.printf "\n=== Testing Simple Game with Advanced Moves ===\n";
  
  let simple_pgn = "[Event \"Test\"]\n[White \"Player1\"]\n[Black \"Player2\"]\n\n1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 7. Bb3 d6 8. c3 O-O 9. h3 Nb8 10. d4 Nbd7 11. Nc3 Bb7 12. Bc2 Re8 13. Nf1 Bf8 14. Ng3 g6 15. a4 c5 16. d5 c4 17. Bg5 h6 18. Be3 Nc5 19. Qd2 Kh7 20. Rae1 Qd7 21. Bg5 Bg7 22. f3 Rae8 23. Kh2 Qf7 24. Nf1 f5 25. exf5 gxf5 26. f4 exf4 27. Bxf4 Qe7 28. Qe2 Qe5 29. Qxe5 dxe5 30. Be3 f4 31. Bf2 e4 32. Ng1 Bc8 33. N1e2 Bd7 34. b4 cxb3 35. Bxb3 Bc5 36. Nc3 Bb6 37. Ncd5 Bxd5 38. Nxd5 Re5 39. c4 bxc4 40. Bxc4 Rg5 41. Bf1 Rxg2+ 42. Kxg2 e3+ 43. Kg1 e2 44. Bxe2 f3 45. Bxf3 Nxf3+ 46. Kf2 Nxd2 47. Nc7 Nxf1 48. Kf1 Rf8+ 49. Ke1 Rf2 50. Kd1 Rd2+ 51. Kc1 Rd1#" in
  
  match parse_game simple_pgn with
  | Ok game ->
      Printf.printf "✅ Successfully parsed game:\n";
      Printf.printf "   White: %s\n" (match game.info.white with Some w -> w.name | None -> "Unknown");
      Printf.printf "   Black: %s\n" (match game.info.black with Some b -> b.name | None -> "Unknown");
      Printf.printf "   Moves: %d\n" (List.length game.moves);
      Printf.printf "   Result: %s\n" (match game.info.result with 
        | Some r -> (match r with WhiteWin -> "1-0" | BlackWin -> "0-1" | Draw -> "1/2-1/2" | Ongoing -> "*")
        | None -> "None");
      true
  | Error e ->
      Printf.printf "❌ Failed to parse game:\n";
      pp_error Format.std_formatter e;
      Printf.printf "\n";
      false

(** Test piece move source position bug fix *)
let test_piece_source_positions () =
  Printf.printf "\n=== Testing Piece Move Source Position Bug Fix ===\n";
  
  let test_cases = [
    (* These were the problematic moves from the bug report *)
    ("Ne3", "Knight to e3");
    ("Bg7", "Bishop to g7");
    ("Nf3", "Knight to f3");
    ("Be4", "Bishop to e4");
    
    (* Additional knight moves to test L-shape movement *)
    ("Nc3", "Knight to c3");
    ("Nd4", "Knight to d4");
    ("Nf6", "Knight to f6");
    ("Ng5", "Knight to g5");
    ("Na3", "Knight to a3");
    ("Nh6", "Knight to h6");
    
    (* Additional bishop moves to test diagonal movement *)
    ("Bd3", "Bishop to d3");
    ("Bf4", "Bishop to f4");
    ("Bh3", "Bishop to h3");
    ("Bc6", "Bishop to c6");
    ("Be7", "Bishop to e7");
    ("Bg2", "Bishop to g2");
    
    (* Rook moves to test horizontal/vertical movement *)
    ("Re1", "Rook to e1");
    ("Rf8", "Rook to f8");
    ("Ra4", "Rook to a4");
    ("Rh5", "Rook to h5");
    
    (* Queen moves to test combined movement *)
    ("Qd2", "Queen to d2");
    ("Qf7", "Queen to f7");
    ("Qa5", "Queen to a5");
    ("Qh4", "Queen to h4");
    
    (* King moves to test single square movement *)
    ("Ke2", "King to e2");
    ("Kf7", "King to f7");
    ("Kc3", "King to c3");
    ("Kg6", "King to g6");
    
    (* Capture moves to test source position calculation *)
    ("Nxe4", "Knight captures on e4");
    ("Bxf7", "Bishop captures on f7");
    ("Rxd5", "Rook captures on d5");
    ("Qxe8", "Queen captures on e8");
    ("Kxf2", "King captures on f2");
  ] in
  
  let results = List.map (fun (move_str, description) ->
    match parse_simple_move move_str with
    | Ok move ->
        let (from_square, to_square, piece) = match move with
          | Normal (piece, from, dest) -> (from, dest, piece)
          | Capture (piece, from, dest, _) -> (from, dest, piece)
          | _ -> (('a', 1), ('a', 1), Pawn)  (* Shouldn't happen for these moves *)
        in
        let (from_file, from_rank) = from_square in
        let (to_file, to_rank) = to_square in
        
        (* Check if the move is valid for the piece type *)
        let is_valid = match piece with
          | Knight ->
              (* Knights move in L-shape: 2 squares in one direction, 1 square perpendicular *)
              let file_diff = abs (int_of_char from_file - int_of_char to_file) in
              let rank_diff = abs (from_rank - to_rank) in
              (file_diff = 1 && rank_diff = 2) || (file_diff = 2 && rank_diff = 1)
          | Bishop ->
              (* Bishops move diagonally *)
              let file_diff = abs (int_of_char from_file - int_of_char to_file) in
              let rank_diff = abs (from_rank - to_rank) in
              file_diff = rank_diff
          | Rook ->
              (* Rooks move horizontally or vertically *)
              let file_diff = abs (int_of_char from_file - int_of_char to_file) in
              let rank_diff = abs (from_rank - to_rank) in
              (file_diff = 0 && rank_diff > 0) || (file_diff > 0 && rank_diff = 0)
          | Queen ->
              (* Queens can move like rooks or bishops *)
              let file_diff = abs (int_of_char from_file - int_of_char to_file) in
              let rank_diff = abs (from_rank - to_rank) in
              (* Either horizontal/vertical (like rook) or diagonal (like bishop) *)
              (file_diff = 0 && rank_diff > 0) || (file_diff > 0 && rank_diff = 0) || (file_diff = rank_diff)
          | King ->
              (* Kings move one square in any direction *)
              let file_diff = abs (int_of_char from_file - int_of_char to_file) in
              let rank_diff = abs (from_rank - to_rank) in
              file_diff <= 1 && rank_diff <= 1 && (file_diff > 0 || rank_diff > 0)
          | Pawn ->
              (* Pawns move forward (or diagonally for captures) *)
              (* For this test, we'll assume it's a forward move *)
              let file_diff = abs (int_of_char from_file - int_of_char to_file) in
              let rank_diff = to_rank - from_rank in
              file_diff = 0 && rank_diff > 0
        in
        
        if is_valid then
          Printf.printf "✅ %s: %s -> from %c%d to %c%d (VALID)\n" 
            description move_str from_file from_rank to_file to_rank
        else
          Printf.printf "❌ %s: %s -> from %c%d to %c%d (INVALID)\n" 
            description move_str from_file from_rank to_file to_rank;
        is_valid
    | Error e ->
        Printf.printf "❌ %s: %s - Error: " description move_str;
        pp_error Format.std_formatter e;
        Printf.printf "\n";
        false
  ) test_cases in
  
  let passed = List.fold_left (fun acc x -> if x then acc + 1 else acc) 0 results in
  let total = List.length results in
  
  Printf.printf "\n=== Results ===\n";
  Printf.printf "Passed: %d/%d piece source position tests\n" passed total;
  
  passed = total

(** Test complex piece movement scenarios *)
let test_complex_piece_scenarios () =
  Printf.printf "\n=== Testing Complex Piece Movement Scenarios ===\n";
  
  let test_cases = [
    (* Edge cases for knight movement *)
    ("Na1", "Knight to a1 (edge case)");
    ("Nh8", "Knight to h8 (edge case)");
    ("Na8", "Knight to a8 (edge case)");
    ("Nh1", "Knight to h1 (edge case)");
    
    (* Edge cases for bishop movement *)
    ("Ba1", "Bishop to a1 (edge case)");
    ("Bh8", "Bishop to h8 (edge case)");
    ("Ba8", "Bishop to a8 (edge case)");
    ("Bh1", "Bishop to h1 (edge case)");
    
    (* Complex captures with different pieces *)
    ("Nxe5+", "Knight captures on e5 with check");
    ("Bxf7#", "Bishop captures on f7 with checkmate");
    ("Rxe8+", "Rook captures on e8 with check");
    ("Qxf7+", "Queen captures on f7 with check");
    ("Kxe2", "King captures on e2");
    
    (* Moves to center squares *)
    ("Ne4", "Knight to e4 (center)");
    ("Bd4", "Bishop to d4 (center)");
    ("Re4", "Rook to e4 (center)");
    ("Qd4", "Queen to d4 (center)");
    ("Ke4", "King to e4 (center)");
  ] in
  
  let results = List.map (fun (move_str, description) ->
    match parse_simple_move move_str with
    | Ok move ->
        let (from_square, to_square, piece) = match move with
          | Normal (piece, from, dest) -> (from, dest, piece)
          | Capture (piece, from, dest, _) -> (from, dest, piece)
          | _ -> (('a', 1), ('a', 1), Pawn)  (* Shouldn't happen for these moves *)
        in
        let (from_file, from_rank) = from_square in
        let (to_file, to_rank) = to_square in
        
        (* Check if the move is valid for the piece type *)
        let is_valid = match piece with
          | Knight ->
              let file_diff = abs (int_of_char from_file - int_of_char to_file) in
              let rank_diff = abs (from_rank - to_rank) in
              (file_diff = 1 && rank_diff = 2) || (file_diff = 2 && rank_diff = 1)
          | Bishop ->
              let file_diff = abs (int_of_char from_file - int_of_char to_file) in
              let rank_diff = abs (from_rank - to_rank) in
              file_diff = rank_diff
          | Rook ->
              let file_diff = abs (int_of_char from_file - int_of_char to_file) in
              let rank_diff = abs (from_rank - to_rank) in
              (file_diff = 0 && rank_diff > 0) || (file_diff > 0 && rank_diff = 0)
          | Queen ->
              let file_diff = abs (int_of_char from_file - int_of_char to_file) in
              let rank_diff = abs (from_rank - to_rank) in
              (file_diff = 0 && rank_diff > 0) || (file_diff > 0 && rank_diff = 0) || (file_diff = rank_diff)
          | King ->
              let file_diff = abs (int_of_char from_file - int_of_char to_file) in
              let rank_diff = abs (from_rank - to_rank) in
              file_diff <= 1 && rank_diff <= 1 && (file_diff > 0 || rank_diff > 0)
          | Pawn ->
              let file_diff = abs (int_of_char from_file - int_of_char to_file) in
              let rank_diff = to_rank - from_rank in
              file_diff = 0 && rank_diff > 0
        in
        
        if is_valid then
          Printf.printf "✅ %s: %s -> from %c%d to %c%d (VALID)\n" 
            description move_str from_file from_rank to_file to_rank
        else
          Printf.printf "❌ %s: %s -> from %c%d to %c%d (INVALID)\n" 
            description move_str from_file from_rank to_file to_rank;
        is_valid
    | Error e ->
        Printf.printf "❌ %s: %s - Error: " description move_str;
        pp_error Format.std_formatter e;
        Printf.printf "\n";
        false
  ) test_cases in
  
  let passed = List.fold_left (fun acc x -> if x then acc + 1 else acc) 0 results in
  let total = List.length results in
  
  Printf.printf "\n=== Results ===\n";
  Printf.printf "Passed: %d/%d complex piece scenario tests\n" passed total;
  
  passed = total

(** Test edge cases *)
let test_edge_cases () =
  Printf.printf "\n=== Testing Edge Cases ===\n";
  
  let test_cases = [
    (* Edge case moves *)
    ("a1", "Pawn to a1 (edge case)");
    ("h8", "Pawn to h8 (edge case)");
    ("Ka1", "King to a1");
    ("Qh8", "Queen to h8");
    ("Ka8", "King to a8");
    ("Qh1", "Queen to h1");
    
    (* Unusual but valid moves *)
    ("O-O+", "Kingside castling with check");
    ("O-O-O#", "Queenside castling with checkmate");
    ("O-O-O+", "Queenside castling with check");
    ("O-O#", "Kingside castling with checkmate");
  ] in
  
  let results = List.map (fun (move_str, description) ->
    match parse_simple_move move_str with
    | Ok _move ->
        Printf.printf "✅ %s: %s\n" description move_str;
        true
    | Error e ->
        Printf.printf "❌ %s: %s - Error: " description move_str;
        pp_error Format.std_formatter e;
        Printf.printf "\n";
        false
  ) test_cases in
  
  let passed = List.fold_left (fun acc x -> if x then acc + 1 else acc) 0 results in
  let total = List.length results in
  
  Printf.printf "\n=== Results ===\n";
  Printf.printf "Passed: %d/%d edge case tests\n" passed total;
  
  passed = total

(** Main test runner *)
let () =
  Printf.printf "🎯 Advanced Move Parsing Tests\n";
  Printf.printf "==============================\n\n";
  
  let test1 = test_disambiguation_moves () in
  let test2 = test_complex_captures () in
  let test3 = test_en_passant_moves () in
  let test4 = test_promotion_moves () in
  let test5 = test_simple_game () in
  let test6 = test_piece_source_positions () in
  let test7 = test_complex_piece_scenarios () in
  let test8 = test_edge_cases () in
  let test9 = test_invalid_moves () in
  
  let results = [test1; test2; test3; test4; test5; test6; test7; test8; test9] in
  let passed = List.fold_left (fun acc x -> if x then acc + 1 else acc) 0 results in
  let total = List.length results in
  
  Printf.printf "\n=== Final Results ===\n";
  Printf.printf "Passed: %d/%d advanced move parsing tests\n" passed total;
  
  if passed = total then
    Printf.printf "🎉 All advanced move parsing tests passed!\n"
  else
    Printf.printf "❌ Some advanced move parsing tests failed\n";
  
  exit (if passed = total then 0 else 1)
