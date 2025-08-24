open Pgn_parser

let demo_hash_properties () =
  Printf.printf "=== Zobrist Hash Properties Demo ===\n\n";
  
  (* Test determinism *)
  let board = create_starting_position () in
  let hash1 = calculate_zobrist_hash board in
  let hash2 = calculate_zobrist_hash board in
  let hash3 = calculate_zobrist_hash board in
  
  Printf.printf "Determinism test:\n";
  Printf.printf "Hash 1: %Ld\n" hash1;
  Printf.printf "Hash 2: %Ld\n" hash2;
  Printf.printf "Hash 3: %Ld\n" hash3;
  Printf.printf "All equal: %b\n\n" (zobrist_equal hash1 hash2 && zobrist_equal hash2 hash3);
  
  (* Test uniqueness *)
  let empty_board = create_empty_board () in
  let empty_hash = calculate_zobrist_hash empty_board in
  
  Printf.printf "Uniqueness test:\n";
  Printf.printf "Starting position hash: %Ld\n" hash1;
  Printf.printf "Empty board hash: %Ld\n" empty_hash;
  Printf.printf "Different: %b\n\n" (not (zobrist_equal hash1 empty_hash))

let demo_move_sequences () =
  Printf.printf "=== Move Sequences Demo ===\n\n";
  
  let board = create_starting_position () in
  let initial_hash = calculate_zobrist_hash board in
  
  Printf.printf "Starting position hash: %Ld\n" initial_hash;
  
  (* Apply e4 *)
  let e4_move = Normal (Pawn, ('e', 2), ('e', 4)) in
  let board_after_e4 = apply_move_to_board board e4_move true in
  let hash_after_e4 = calculate_zobrist_hash board_after_e4 in
  
  Printf.printf "After e4 hash: %Ld\n" hash_after_e4;
  Printf.printf "Changed: %b\n" (not (zobrist_equal initial_hash hash_after_e4));
  
  (* Apply e5 *)
  let e5_move = Normal (Pawn, ('e', 7), ('e', 5)) in
  let board_after_e5 = apply_move_to_board board_after_e4 e5_move false in
  let hash_after_e5 = calculate_zobrist_hash board_after_e5 in
  
  Printf.printf "After e5 hash: %Ld\n" hash_after_e5;
  Printf.printf "Changed from e4: %b\n" (not (zobrist_equal hash_after_e4 hash_after_e5));
  
  (* Apply Nf3 *)
  let nf3_move = Normal (Knight, ('g', 1), ('f', 3)) in
  let board_after_nf3 = apply_move_to_board board_after_e5 nf3_move true in
  let hash_after_nf3 = calculate_zobrist_hash board_after_nf3 in
  
  Printf.printf "After Nf3 hash: %Ld\n" hash_after_nf3;
  Printf.printf "Changed from e5: %b\n\n" (not (zobrist_equal hash_after_e5 hash_after_nf3))

let demo_position_comparison () =
  Printf.printf "=== Position Comparison Demo ===\n\n";
  
  (* Create two identical positions *)
  let board1 = create_starting_position () in
  let board2 = create_starting_position () in
  
  Printf.printf "Two starting positions:\n";
  Printf.printf "Board 1 hash: %Ld\n" (calculate_zobrist_hash board1);
  Printf.printf "Board 2 hash: %Ld\n" (calculate_zobrist_hash board2);
  Printf.printf "Positions equal: %b\n" (positions_equal board1 board2);
  Printf.printf "Hashes equal: %b\n\n" (zobrist_equal (calculate_zobrist_hash board1) (calculate_zobrist_hash board2));
  
  (* Create different positions *)
  let e4_move = Normal (Pawn, ('e', 2), ('e', 4)) in
  let board3 = apply_move_to_board board1 e4_move true in
  
  Printf.printf "Different positions:\n";
  Printf.printf "Board 1 hash: %Ld\n" (calculate_zobrist_hash board1);
  Printf.printf "Board 3 hash: %Ld\n" (calculate_zobrist_hash board3);
  Printf.printf "Positions equal: %b\n" (positions_equal board1 board3);
  Printf.printf "Hashes equal: %b\n\n" (zobrist_equal (calculate_zobrist_hash board1) (calculate_zobrist_hash board3))

let demo_transposition () =
  Printf.printf "=== Transposition Demo ===\n\n";
  
  (* Path 1: e4, e5 *)
  let board = create_starting_position () in
  let board1 = apply_move_to_board board (Normal (Pawn, ('e', 2), ('e', 4))) true in
  let board1 = apply_move_to_board board1 (Normal (Pawn, ('e', 7), ('e', 5))) false in
  
  (* Path 2: e5, e4 (simulated) *)
  let board2 = create_starting_position () in
  board2.(4).(3) <- (Some Pawn, true);   (* e4 *)
  board2.(4).(1) <- (None, false);       (* remove pawn from e2 *)
  board2.(4).(4) <- (Some Pawn, false);  (* e5 *)
  board2.(4).(6) <- (None, false);       (* remove pawn from e7 *)
  
  let hash1 = calculate_zobrist_hash board1 in
  let hash2 = calculate_zobrist_hash board2 in
  
  Printf.printf "Transposition test:\n";
  Printf.printf "Path 1 (e4, e5) hash: %Ld\n" hash1;
  Printf.printf "Path 2 (e5, e4) hash: %Ld\n" hash2;
  Printf.printf "Positions equal: %b\n" (positions_equal board1 board2);
  Printf.printf "Hashes equal: %b\n" (zobrist_equal hash1 hash2)

let demo_game_analysis () =
  Printf.printf "\n=== Game Analysis Demo ===\n\n";
  
  let pgn = "[Event \"Test Game\"]\n[White \"W\"]\n[Black \"B\"]\n\n1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Bxc6 dxc6" in
  
  match parse_game pgn with
  | Ok game ->
      Printf.printf "Game analysis:\n";
      Printf.printf "Total moves: %d\n" (List.length game.moves);
      
      (* Collect all position hashes *)
      let all_hashes = ref [] in
      List.iter (fun move ->
        (match move.zobrist_after_white with
         | Some hash -> all_hashes := hash :: !all_hashes
         | None -> ());
        (match move.zobrist_after_black with
         | Some hash -> all_hashes := hash :: !all_hashes
         | None -> ())
      ) game.moves;
      
      let unique_hashes = List.sort_uniq Int64.compare !all_hashes in
      Printf.printf "Total positions: %d\n" (List.length !all_hashes);
      Printf.printf "Unique positions: %d\n" (List.length unique_hashes);
      Printf.printf "Repeated positions: %d\n" ((List.length !all_hashes) - (List.length unique_hashes));
      
      (* Show position hashes *)
      Printf.printf "\nPosition hashes:\n";
      List.iteri (fun i hash -> 
        Printf.printf "Position %d: %Ld\n" (i + 1) hash
      ) unique_hashes;
      
  | Error e ->
      Printf.printf "Error: %s\n" (match e with
        | InvalidMove s -> s | InvalidTag s -> s 
        | InvalidFormat s -> s | UnexpectedEnd s -> s)

let () =
  Printf.printf "🎯 PGN Parser - Zobrist Hash Demo\n";
  Printf.printf "=================================\n\n";
  
  demo_hash_properties ();
  demo_move_sequences ();
  demo_position_comparison ();
  demo_transposition ();
  demo_game_analysis ();
  
  Printf.printf "\n✅ Zobrist hash demo completed!\n"
