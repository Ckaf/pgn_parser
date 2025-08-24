open Pgn_parser

let demo_basic_parsing () =
  Printf.printf "=== Basic PGN Parsing Demo ===\n\n";
  
  let pgn = "[Event \"Test Game\"]\n[Site \"Test Site\"]\n[Date \"2024.01.01\"]\n[White \"Alice\"]\n[Black \"Bob\"]\n\n1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Bxc6 dxc6 5. O-O" in
  
  match parse_game pgn with
  | Ok game ->
      Printf.printf "Game parsed successfully!\n";
      Printf.printf "Event: %s\n" (match game.info.event with Some e -> e | None -> "Unknown");
      Printf.printf "Site: %s\n" (match game.info.site with Some s -> s | None -> "Unknown");
      Printf.printf "Date: %s\n" (match game.info.date with Some d -> d | None -> "Unknown");
      Printf.printf "White: %s\n" (match game.info.white with Some w -> w.name | None -> "Unknown");
      Printf.printf "Black: %s\n" (match game.info.black with Some b -> b.name | None -> "Unknown");
      Printf.printf "Number of moves: %d\n\n" (List.length game.moves);
      
      (* Show moves *)
      List.iter (fun move ->
        Printf.printf "Move %d:\n" move.number;
        (match move.white_move with
         | Some white_move -> Printf.printf "  White: %s\n" (format_move_type white_move)
         | None -> ());
        (match move.black_move with
         | Some black_move -> Printf.printf "  Black: %s\n" (format_move_type black_move)
         | None -> ())
      ) game.moves;
      
      (* Show reconstructed PGN *)
      Printf.printf "\nReconstructed PGN:\n%s\n" (to_pgn game);
      
  | Error e ->
      Printf.printf "Error parsing PGN: %s\n" (match e with
        | InvalidMove s -> "Invalid move: " ^ s
        | InvalidTag s -> "Invalid tag: " ^ s
        | InvalidFormat s -> "Invalid format: " ^ s
        | UnexpectedEnd s -> "Unexpected end: " ^ s)

let demo_move_types () =
  Printf.printf "\n=== Move Types Demo ===\n\n";
  
  let pgn = "[Event \"Move Types\"]\n[White \"W\"]\n[Black \"B\"]\n\n1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Bxc6 dxc6 5. O-O O-O-O 6. d4 exd4 7. Nxd4 Nxd4 8. Qxd4 Qxd4 9. Rxd4 g8=Q" in
  
  match parse_game pgn with
  | Ok game ->
      Printf.printf "Game with various move types:\n";
      List.iter (fun move ->
        Printf.printf "Move %d:\n" move.number;
        (match move.white_move with
         | Some white_move -> 
             let move_type = match white_move with
               | Normal _ -> "Normal"
               | Capture _ -> "Capture"
               | Castle _ -> "Castle"
               | EnPassant _ -> "En Passant"
               | Promotion _ -> "Promotion"
               | Check -> "Check"
               | Checkmate -> "Checkmate"
               | Draw -> "Draw"
             in
             Printf.printf "  White: %s (%s)\n" (format_move_type white_move) move_type
         | None -> ());
        (match move.black_move with
         | Some black_move -> 
             let move_type = match black_move with
               | Normal _ -> "Normal"
               | Capture _ -> "Capture"
               | Castle _ -> "Castle"
               | EnPassant _ -> "En Passant"
               | Promotion _ -> "Promotion"
               | Check -> "Check"
               | Checkmate -> "Checkmate"
               | Draw -> "Draw"
             in
             Printf.printf "  Black: %s (%s)\n" (format_move_type black_move) move_type
         | None -> ())
      ) game.moves;
      
  | Error e ->
      Printf.printf "Error: %s\n" (match e with
        | InvalidMove s -> s | InvalidTag s -> s 
        | InvalidFormat s -> s | UnexpectedEnd s -> s)

let demo_error_handling () =
  Printf.printf "\n=== Error Handling Demo ===\n\n";
  
  let invalid_pgns = [
    "1. e9";  (* Invalid square *)
    "1. Xf3"; (* Invalid piece *)
    "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Bxc6 dxc6 5. O-O-O-O"; (* Invalid castling *)
    "[Event \"Test\"]\n[White \"Player\"]\n1. e4"; (* Missing Black tag *)
  ] in
  
  List.iteri (fun i pgn ->
    Printf.printf "Test %d:\n" (i + 1);
    Printf.printf "Input: %s\n" pgn;
    match parse_game pgn with
    | Ok _ -> Printf.printf "Result: Success (unexpected)\n"
    | Error e -> Printf.printf "Result: Error - %s\n" (match e with
        | InvalidMove s -> "Invalid move: " ^ s
        | InvalidTag s -> "Invalid tag: " ^ s
        | InvalidFormat s -> "Invalid format: " ^ s
        | UnexpectedEnd s -> "Unexpected end: " ^ s)
  ) invalid_pgns

let () =
  Printf.printf "🎯 PGN Parser - Basic Features Demo\n";
  Printf.printf "===================================\n\n";
  
  demo_basic_parsing ();
  demo_move_types ();
  demo_error_handling ();
  
  Printf.printf "\n✅ Basic PGN demo completed!\n"
