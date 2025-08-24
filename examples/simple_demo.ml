open Pgn_parser

(** Simple demo without network requests *)
let demo_basic_parsing () =
  Printf.printf "=== Basic PGN Parsing Demo ===\n";
  
  let pgn = "[Event \"Test Game\"]\n[Site \"Test Site\"]\n[Date \"2024.01.01\"]\n[White \"Alice\"]\n[Black \"Bob\"]\n\n1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Bxc6 dxc6 5. O-O" in
  
  match parse_game pgn with
  | Ok game ->
      Printf.printf "✅ Parsed successfully!\n";
      Printf.printf "White: %s\n" (match game.info.white with Some w -> w.name | None -> "Unknown");
      Printf.printf "Black: %s\n" (match game.info.black with Some b -> b.name | None -> "Unknown");
      Printf.printf "Event: %s\n" (match game.info.event with Some e -> e | None -> "Unknown");
      Printf.printf "Number of moves: %d\n" (List.length game.moves);
      
      Printf.printf "\nFirst 3 moves:\n";
      List.iteri (fun i move ->
        if i < 3 then
          Printf.printf "Move %d: " move.number;
          (match move.white_move with
           | Some (Normal (piece, _, to_sq)) -> 
               Printf.printf "%s%s" 
                 (match piece with King -> "K" | Queen -> "Q" | Rook -> "R" | Bishop -> "B" | Knight -> "N" | Pawn -> "")
                 (Printf.sprintf "%c%d" (fst to_sq) (snd to_sq))
           | Some (Castle true) -> Printf.printf "O-O"
           | Some (Castle false) -> Printf.printf "O-O-O"
                       | Some (Capture (piece, _, to_sq, _)) ->
                Printf.printf "%sx%s" 
                  (match piece with King -> "K" | Queen -> "Q" | Rook -> "R" | Bishop -> "B" | Knight -> "N" | Pawn -> "")
                  (Printf.sprintf "%c%d" (fst to_sq) (snd to_sq))
                       | Some (Promotion (_, _, piece)) ->
                Printf.printf "=%s" 
                  (match piece with King -> "K" | Queen -> "Q" | Rook -> "R" | Bishop -> "B" | Knight -> "N" | Pawn -> "P")
           | _ -> Printf.printf "??");
          (match move.black_move with
           | Some (Normal (piece, _, to_sq)) -> 
               Printf.printf " %s%s" 
                 (match piece with King -> "K" | Queen -> "Q" | Rook -> "R" | Bishop -> "B" | Knight -> "N" | Pawn -> "")
                 (Printf.sprintf "%c%d" (fst to_sq) (snd to_sq))
           | Some (Castle true) -> Printf.printf " O-O"
           | Some (Castle false) -> Printf.printf " O-O-O"
                       | Some (Capture (piece, _, to_sq, _)) ->
                Printf.printf " %sx%s" 
                  (match piece with King -> "K" | Queen -> "Q" | Rook -> "R" | Bishop -> "B" | Knight -> "N" | Pawn -> "")
                  (Printf.sprintf "%c%d" (fst to_sq) (snd to_sq))
                       | Some (Promotion (_, _, piece)) ->
                Printf.printf " =%s" 
                  (match piece with King -> "K" | Queen -> "Q" | Rook -> "R" | Bishop -> "B" | Knight -> "N" | Pawn -> "P")
           | _ -> Printf.printf " ??");
          Printf.printf "\n"
      ) game.moves;
      
      Printf.printf "\nReconstructed PGN:\n%s\n" (to_pgn game)
  | Error e ->
      Printf.printf "❌ Failed to parse: ";
      pp_error Format.std_formatter e;
      Printf.printf "\n"

let demo_zobrist_hashing () =
  Printf.printf "\n=== Zobrist Hashing Demo ===\n";
  
  let board = create_starting_position () in
  let hash1 = calculate_zobrist_hash board in
  let hash2 = calculate_zobrist_hash board in
  
  Printf.printf "Starting position hash: %Ld\n" hash1;
  Printf.printf "Hash determinism: %s\n" (if hash1 = hash2 then "✅" else "❌");
  
  (* Make a move *)
  let board_after_e4 = apply_move_to_board board (Normal (Pawn, ('e', 2), ('e', 4))) true in
  let hash_after_e4 = calculate_zobrist_hash board_after_e4 in
  
  Printf.printf "After e4 hash: %Ld\n" hash_after_e4;
  Printf.printf "Hash changed: %s\n" (if hash1 <> hash_after_e4 then "✅" else "❌")

let demo_board_visualization () =
  Printf.printf "\n=== Board Visualization Demo ===\n";
  
  let board = create_starting_position () in
  Printf.printf "Starting position:\n%s\n" (board_to_string board);
  
  let board_after_e4 = apply_move_to_board board (Normal (Pawn, ('e', 2), ('e', 4))) true in
  Printf.printf "After e4:\n%s\n" (board_to_string board_after_e4);
  
  let board_after_e5 = apply_move_to_board board_after_e4 (Normal (Pawn, ('e', 7), ('e', 5))) false in
  Printf.printf "After e5:\n%s\n" (board_to_string board_after_e5)

let demo_error_handling () =
  Printf.printf "\n=== Error Handling Demo ===\n";
  
  let invalid_pgns = [
    "1. e9";  (* Invalid square *)
    "1. Xf3"; (* Invalid piece *)
    "1. e4 e5 2. O-O-O-O"; (* Invalid castling *)
    "[Event \"Test\"]\n1. e4"; (* Incomplete game *)
  ] in
  
  List.iteri (fun i pgn ->
    Printf.printf "Test %d:\n" (i + 1);
    Printf.printf "Input: %s\n" pgn;
    match parse_game pgn with
    | Ok _ -> Printf.printf "Result: Success (unexpected)\n"
    | Error e -> 
        Printf.printf "Result: Error - ";
        pp_error Format.std_formatter e;
        Printf.printf "\n"
  ) invalid_pgns

(** Main function *)
let () =
  Printf.printf "🎯 PGN Parser - Simple Demo\n";
  Printf.printf "===========================\n";
  
  demo_basic_parsing ();
  demo_zobrist_hashing ();
  demo_board_visualization ();
  demo_error_handling ();
  
  Printf.printf "\n✅ Simple demo completed!\n"
