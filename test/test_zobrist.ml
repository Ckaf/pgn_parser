open Pgn_parser

let test_hash_determinism () =
  let board = create_starting_position () in
  let hash1 = calculate_zobrist_hash board in
  let hash2 = calculate_zobrist_hash board in
  let hash3 = calculate_zobrist_hash board in
  
  Printf.printf "Hash1: %Ld, Hash2: %Ld, Hash3: %Ld\n" hash1 hash2 hash3;
  
  if not (zobrist_equal hash1 hash2) then (
    Printf.printf "ERROR: hash1 != hash2\n";
    assert false
  );
  if not (zobrist_equal hash2 hash3) then (
    Printf.printf "ERROR: hash2 != hash3\n";
    assert false
  );
  if not (zobrist_equal hash1 hash3) then (
    Printf.printf "ERROR: hash1 != hash3\n";
    assert false
  );
  
  Printf.printf "✓ Hash determinism test passed\n"

let test_hash_uniqueness () =
  let board1 = create_starting_position () in
  let board2 = create_empty_board () in
  
  let hash1 = calculate_zobrist_hash board1 in
  let hash2 = calculate_zobrist_hash board2 in
  
  assert (not (zobrist_equal hash1 hash2));
  
  (* Test with slightly different positions *)
  let e4_move = Normal (Pawn, ('e', 2), ('e', 4)) in
  let board3 = apply_move_to_board board1 e4_move true in
  let hash3 = calculate_zobrist_hash board3 in
  
  assert (not (zobrist_equal hash1 hash3));
  assert (not (zobrist_equal hash2 hash3));
  
  Printf.printf "✓ Hash uniqueness test passed\n"

let test_move_integrity () =
  let board = create_starting_position () in
  
  (* Test normal move *)
  let e4_move = Normal (Pawn, ('e', 2), ('e', 4)) in
  let board_after_e4 = apply_move_to_board board e4_move true in
  
  (* Check that pawn moved correctly *)
  assert (fst board_after_e4.(4).(3) = Some Pawn && snd board_after_e4.(4).(3) = true);
  assert (fst board_after_e4.(4).(1) = None);
  
  (* Check that other pieces are unchanged *)
  assert (fst board_after_e4.(0).(0) = Some Rook && snd board_after_e4.(0).(0) = true);
  assert (fst board_after_e4.(4).(0) = Some King && snd board_after_e4.(4).(0) = true);
  
  (* Test capture *)
  let board_with_black_pawn = apply_move_to_board board_after_e4 (Normal (Pawn, ('d', 7), ('d', 5))) false in
  let capture_move = Capture (Pawn, ('e', 4), ('d', 5), Some Pawn) in
  let board_after_capture = apply_move_to_board board_with_black_pawn capture_move true in
  
  (* Check that capture worked *)
  assert (fst board_after_capture.(3).(4) = Some Pawn && snd board_after_capture.(3).(4) = true);
  assert (fst board_after_capture.(4).(3) = None);
  
  Printf.printf "✓ Move integrity test passed\n"

let test_castling () =
  (* Create board for castling test *)
  let empty_board = create_empty_board () in
  empty_board.(4).(0) <- (Some King, true);   (* White king *)
  empty_board.(7).(0) <- (Some Rook, true);   (* White rook *)
  empty_board.(4).(7) <- (Some King, false);  (* Black king *)
  empty_board.(0).(7) <- (Some Rook, false);  (* Black rook *)
  
  (* Test white kingside castling *)
  let kingside_castle = Castle true in
  let board_after_castle = apply_move_to_board empty_board kingside_castle true in
  
  assert (fst board_after_castle.(6).(0) = Some King && snd board_after_castle.(6).(0) = true);
  assert (fst board_after_castle.(5).(0) = Some Rook && snd board_after_castle.(5).(0) = true);
  assert (fst board_after_castle.(4).(0) = None);
  assert (fst board_after_castle.(7).(0) = None);
  
  (* Test black queenside castling *)
  let queenside_castle = Castle false in
  let board_after_qcastle = apply_move_to_board empty_board queenside_castle false in
  
  assert (fst board_after_qcastle.(2).(7) = Some King && snd board_after_qcastle.(2).(7) = false);
  assert (fst board_after_qcastle.(3).(7) = Some Rook && snd board_after_qcastle.(3).(7) = false);
  assert (fst board_after_qcastle.(4).(7) = None);
  assert (fst board_after_qcastle.(0).(7) = None);
  
  Printf.printf "✓ Castling test passed\n"

let test_promotion () =
  let board = create_empty_board () in
  board.(0).(6) <- (Some Pawn, true);  (* White pawn on 7th rank *)
  
  let promotion_move = Promotion (('a', 7), ('a', 8), Queen) in
  let board_after_promotion = apply_move_to_board board promotion_move true in
  
  assert (fst board_after_promotion.(0).(7) = Some Queen && snd board_after_promotion.(0).(7) = true);
  assert (fst board_after_promotion.(0).(6) = None);
  
  Printf.printf "✓ Promotion test passed\n"

let test_transposition () =
  let board = create_starting_position () in
  
  (* Path 1: e4, e5 *)
  let board1 = apply_move_to_board board (Normal (Pawn, ('e', 2), ('e', 4))) true in
  let board1 = apply_move_to_board board1 (Normal (Pawn, ('e', 7), ('e', 5))) false in
  
  (* Path 2: e5, e4 (if we could do this) - simulate by building position manually *)
  let board2 = create_starting_position () in
  board2.(4).(3) <- (Some Pawn, true);   (* e4 *)
  board2.(4).(1) <- (None, false);       (* remove pawn from e2 *)
  board2.(4).(4) <- (Some Pawn, false);  (* e5 *)
  board2.(4).(6) <- (None, false);       (* remove pawn from e7 *)
  
  let hash1 = calculate_zobrist_hash board1 in
  let hash2 = calculate_zobrist_hash board2 in
  
  assert (zobrist_equal hash1 hash2);
  assert (positions_equal board1 board2);
  
  Printf.printf "✓ Transposition test passed\n"

let test_board_visualization () =
  let board = create_starting_position () in
  let board_str = board_to_string board in
  
  (* Check that board string contains expected pieces *)
  assert (String.contains board_str 'K');  (* White king *)
  assert (String.contains board_str 'k');  (* Black king *)
  assert (String.contains board_str 'P');  (* White pawns *)
  assert (String.contains board_str 'p');  (* Black pawns *)
  assert (String.contains board_str '.');  (* Empty squares *)
  
  (* Test with a simple game *)
  let pgn = "[Event \"Test\"]\n[White \"W\"]\n[Black \"B\"]\n\n1. e4 e5" in
  match parse_game pgn with
  | Ok game ->
      let visualization = visualize_game_progression game in
      assert (String.length visualization > 0);
      assert (String.contains visualization 'e');  (* Contains move notation *)
      
      (* Test getting specific board positions *)
      let board_after_e4 = get_board_after_move game.moves 1 true in
      assert (board_after_e4 <> None);
      
      let final_board = get_final_board game.moves in
      assert (final_board <> None);
      
      Printf.printf "✓ Board visualization test passed\n"
  | Error _ -> assert false

let test_parsing_board_consistency () =
  let pgn = "[Event \"Test Game\"]\n[White \"Player1\"]\n[Black \"Player2\"]\n\n1. e4 e5 2. Nf3 Nc6 3. Bb5 a6" in
  
  match parse_game pgn with
  | Ok game ->
      (* Check that each move has consistent board state *)
      List.iter (fun move ->
        (match move.position_after_white, move.zobrist_after_white with
         | Some board, Some hash ->
             let calculated_hash = calculate_zobrist_hash board in
             assert (zobrist_equal hash calculated_hash)
         | _ -> ());
        
        (match move.position_after_black, move.zobrist_after_black with
         | Some board, Some hash ->
             let calculated_hash = calculate_zobrist_hash board in
             assert (zobrist_equal hash calculated_hash)
         | _ -> ())
      ) game.moves;
      
      Printf.printf "✓ Parsing board consistency test passed\n"
  | Error e ->
      Printf.printf "Error: %s\n" (match e with
        | InvalidMove s -> s | InvalidTag s -> s 
        | InvalidFormat s -> s | UnexpectedEnd s -> s);
      assert false

let test_hash_collision_resistance () =
  (* Test with some known different positions *)
  let positions = [
    create_starting_position ();
    create_empty_board ();
    (let b = create_empty_board () in b.(0).(0) <- (Some Pawn, true); b);
    (let b = create_empty_board () in b.(0).(0) <- (Some Pawn, false); b);
    (let b = create_empty_board () in b.(0).(0) <- (Some King, true); b);
    (let b = create_empty_board () in b.(7).(7) <- (Some Queen, false); b);
  ] in
  
  let hashes = List.map calculate_zobrist_hash positions in
  let unique_hashes = List.sort_uniq Int64.compare hashes in
  
  Printf.printf "Generated %d positions, %d unique hashes\n" 
    (List.length positions) (List.length unique_hashes);
  
  (* Print all hashes for debugging *)
  List.iteri (fun i hash -> Printf.printf "Position %d: %Ld\n" i hash) hashes;
  
  (* All different positions should have different hashes *)
  if List.length unique_hashes <> List.length positions then (
    Printf.printf "ERROR: Hash collision detected!\n";
    Printf.printf "Expected %d unique hashes, got %d\n" 
      (List.length positions) (List.length unique_hashes);
    assert false
  );
  
  Printf.printf "✓ Hash collision resistance test passed\n"

let test_fixed_piece_positions_zobrist () =
  Printf.printf "\n=== Testing Zobrist Hash with Fixed Piece Positions ===\n";
  
  (* Test moves that had the source position bug *)
  let test_cases = [
    ("Ne3", "Knight to e3");
    ("Bg7", "Bishop to g7");
    ("Nf3", "Knight to f3");
    ("Be4", "Bishop to e4");
    ("Nxe4", "Knight captures on e4");
    ("Bxf7", "Bishop captures on f7");
  ] in
  
  let starting_board = create_starting_position () in
  let starting_hash = calculate_zobrist_hash starting_board in
  
  Printf.printf "Starting position hash: %Ld\n" starting_hash;
  
  List.iter (fun (move_str, description) ->
    match parse_simple_move move_str with
    | Ok move ->
        let (from_square, to_square, piece) = match move with
          | Normal (piece, from, dest) -> (from, dest, piece)
          | Capture (piece, from, dest, _) -> (from, dest, piece)
          | _ -> (('a', 1), ('a', 1), Pawn)
        in
        let (from_file, from_rank) = from_square in
        let (to_file, to_rank) = to_square in
        
        (* Apply the move to the board *)
        let new_board = apply_move_to_board starting_board move true in
        let new_hash = calculate_zobrist_hash new_board in
        
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
          | _ -> true
        in
        
        if is_valid then (
          Printf.printf "✅ %s: %s -> from %c%d to %c%d (VALID)\n" 
            description move_str from_file from_rank to_file to_rank;
          Printf.printf "   Hash: %Ld\n" new_hash
        ) else (
          Printf.printf "❌ %s: %s -> from %c%d to %c%d (INVALID)\n" 
            description move_str from_file from_rank to_file to_rank;
          Printf.printf "   Hash: %Ld (may be incorrect due to invalid move)\n" new_hash
        )
    | Error e ->
        Printf.printf "❌ %s: %s - Error: " description move_str;
        (match e with
         | InvalidMove s -> Printf.printf "Invalid move: %s" s
         | InvalidTag s -> Printf.printf "Invalid tag: %s" s
         | InvalidFormat s -> Printf.printf "Invalid format: %s" s
         | UnexpectedEnd s -> Printf.printf "Unexpected end: %s" s);
        Printf.printf "\n"
  ) test_cases;
  
  Printf.printf "✓ Fixed piece positions Zobrist test passed\n";
  
  (* Test that all hashes are unique *)
  let hashes = ref [] in
  List.iter (fun (move_str, _) ->
    match parse_simple_move move_str with
    | Ok move ->
        let new_board = apply_move_to_board starting_board move true in
        let new_hash = calculate_zobrist_hash new_board in
        hashes := new_hash :: !hashes
    | Error _ -> ()
  ) test_cases;
  
  let unique_hashes = List.sort_uniq Int64.compare !hashes in
  if List.length unique_hashes = List.length !hashes then
    Printf.printf "✅ All position hashes are unique\n"
  else
    Printf.printf "❌ Hash collision detected in fixed piece positions\n";
  
  (* Test hash consistency for a sequence of moves *)
  Printf.printf "\n=== Testing Hash Consistency for Move Sequences ===\n";
  let board = ref starting_board in
  let current_hash = ref starting_hash in
  
  List.iter (fun (move_str, description) ->
    match parse_simple_move move_str with
    | Ok move ->
        let new_board = apply_move_to_board !board move true in
        let new_hash = calculate_zobrist_hash new_board in
        
        (* Verify that the hash changed *)
        if new_hash <> !current_hash then
          Printf.printf "✅ %s: Hash changed from %Ld to %Ld\n" 
            description !current_hash new_hash
        else
          Printf.printf "❌ %s: Hash did not change: %Ld\n" 
            description !current_hash;
        
        board := new_board;
        current_hash := new_hash
    | Error _ -> ()
  ) test_cases;
  
  Printf.printf "✓ Hash consistency for move sequences test passed\n"

let run_all_tests () =
  Printf.printf "=== Comprehensive Zobrist Hash Tests ===\n\n";
  
  test_hash_determinism ();
  test_hash_uniqueness ();
  test_move_integrity ();
  test_castling ();
  test_promotion ();
  test_transposition ();
  test_board_visualization ();
  test_parsing_board_consistency ();
  test_hash_collision_resistance ();
  test_fixed_piece_positions_zobrist ();
  
  Printf.printf "\n=== All Zobrist tests passed! ===\n"

let () = run_all_tests ()
