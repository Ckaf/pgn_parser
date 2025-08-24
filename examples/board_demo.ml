open Pgn_parser

let demo_board_visualization () =
  Printf.printf "=== Board Visualization Demo ===\n\n";
  
  (* Parse a simple game *)
  let pgn = "[Event \"Demo Game\"]\n[White \"Alice\"]\n[Black \"Bob\"]\n\n1. e4 e5 2. Nf3 Nc6 3. Bb5" in
  
  match parse_game pgn with
  | Ok game ->
      Printf.printf "Game: %s vs %s\n\n" 
        (match game.info.white with Some w -> w.name | None -> "Unknown")
        (match game.info.black with Some b -> b.name | None -> "Unknown");
      
      (* Show starting position *)
      Printf.printf "Starting position:\n";
      print_board (create_starting_position ());
      Printf.printf "\n";
      
      (* Show position after each move *)
      List.iter (fun move ->
        Printf.printf "Move %d:\n" move.number;
        
        (match move.white_move, move.position_after_white, move.zobrist_after_white with
         | Some white_move, Some board, Some hash ->
             Printf.printf "After %s (Hash: %Ld):\n" 
               (format_move_type white_move) hash;
             print_board board;
             Printf.printf "\n"
         | _ -> ());
        
        (match move.black_move, move.position_after_black, move.zobrist_after_black with
         | Some black_move, Some board, Some hash ->
             Printf.printf "After %s (Hash: %Ld):\n" 
               (format_move_type black_move) hash;
             print_board board;
             Printf.printf "\n"
         | _ -> ())
      ) game.moves;
      
      (* Show final position *)
      (match get_final_board game.moves with
       | Some final_board ->
           Printf.printf "Final position:\n";
           print_board final_board
       | None -> Printf.printf "No final position available\n");
      
  | Error e ->
      Printf.printf "Error parsing PGN: %s\n" (match e with
        | InvalidMove s -> "Invalid move: " ^ s
        | InvalidTag s -> "Invalid tag: " ^ s
        | InvalidFormat s -> "Invalid format: " ^ s
        | UnexpectedEnd s -> "Unexpected end: " ^ s)

let demo_position_comparison () =
  Printf.printf "\n=== Position Comparison Demo ===\n\n";
  
  let board1 = create_starting_position () in
  let board2 = create_starting_position () in
  
  Printf.printf "Two starting positions:\n";
  Printf.printf "Board 1 hash: %Ld\n" (calculate_zobrist_hash board1);
  Printf.printf "Board 2 hash: %Ld\n" (calculate_zobrist_hash board2);
  Printf.printf "Are equal: %b\n\n" (positions_equal board1 board2);
  
  (* Apply e4 to board2 *)
  let e4_move = Normal (Pawn, ('e', 2), ('e', 4)) in
  let board2_after_e4 = apply_move_to_board board2 e4_move true in
  
  Printf.printf "After e4 on board 2:\n";
  Printf.printf "Board 1 hash: %Ld\n" (calculate_zobrist_hash board1);
  Printf.printf "Board 2 hash: %Ld\n" (calculate_zobrist_hash board2_after_e4);
  Printf.printf "Are equal: %b\n" (positions_equal board1 board2_after_e4)

let () =
  Printf.printf "🎯 PGN Parser - Board Visualization Demo\n";
  Printf.printf "=======================================\n\n";
  
  demo_board_visualization ();
  demo_position_comparison ();
  
  Printf.printf "\n✅ Demo completed!\n"
