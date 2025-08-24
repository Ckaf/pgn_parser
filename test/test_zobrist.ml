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
  
  Printf.printf "\n=== All Zobrist tests passed! ===\n"

let () = run_all_tests ()
