(** PGN Parser *)

open Pgn_parser

let test_pgn = "[Event \"Test Game\"]\n[Site \"Test Site\"]\n[Date \"2024.01.01\"]\n[White \"Player1\"]\n[Black \"Player2\"]\n\n1. e4 e5 2. Nf3 Nc6 1-0"

let complex_pgn = "[Event \"Ruy Lopez\"]\n[Site \"Lichess\"]\n[Date \"2024.01.01\"]\n[White \"Magnus Carlsen\"]\n[Black \"Hikaru Nakamura\"]\n[Result \"1/2-1/2\"]\n\n1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 7. Bb3 d6 8. c3 O-O 9. h3 Nb8 10. d4 Nbd7 1/2-1/2"

(** Test local PGN examples *)
let test_local_examples () =
  Printf.printf "=== Testing Local PGN Examples ===\n\n";
  
  Printf.printf "1. Simple PGN Example:\n";
  Printf.printf "Input:\n%s\n\n" test_pgn;
  
  match parse_game test_pgn with
  | Ok game ->
      Printf.printf "Parsed successfully!\n";
      Printf.printf "White: %s\n" (match game.info.white with Some w -> w.name | None -> "Unknown");
      Printf.printf "Black: %s\n" (match game.info.black with Some b -> b.name | None -> "Unknown");
      Printf.printf "Number of moves: %d\n" (List.length game.moves);
      
      Printf.printf "\nReconstructed PGN:\n%s\n" (to_pgn game)
  | Error e ->
      Printf.printf "Failed to parse: ";
      pp_error Format.std_formatter e;
      Printf.printf "\n";
  
  Printf.printf "\n%s\n\n" (String.make 50 '=');
  
  Printf.printf "2. Complex PGN Example (Ruy Lopez):\n";
  Printf.printf "Input:\n%s\n\n" complex_pgn;
  
  match parse_game complex_pgn with
  | Ok game ->
      Printf.printf "Parsed successfully!\n";
      Printf.printf "White: %s\n" (match game.info.white with Some w -> w.name | None -> "Unknown");
      Printf.printf "Black: %s\n" (match game.info.black with Some b -> b.name | None -> "Unknown");
      Printf.printf "Number of moves: %d\n" (List.length game.moves);
      
      Printf.printf "\nFirst few moves:\n";
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
           | _ -> Printf.printf "??");
          (match move.black_move with
           | Some (Normal (piece, _, to_sq)) -> 
               Printf.printf " %s%s" 
                 (match piece with King -> "K" | Queen -> "Q" | Rook -> "R" | Bishop -> "B" | Knight -> "N" | Pawn -> "")
                 (Printf.sprintf "%c%d" (fst to_sq) (snd to_sq))
           | Some (Castle true) -> Printf.printf " O-O"
           | Some (Castle false) -> Printf.printf " O-O-O"
           | _ -> Printf.printf " ??");
          Printf.printf "\n"
      ) game.moves;
      
      Printf.printf "\nReconstructed PGN:\n%s\n" (to_pgn game)
  | Error e ->
      Printf.printf "Failed to parse: ";
      pp_error Format.std_formatter e;
      Printf.printf "\n"

(** Main function *)
let () =
  test_local_examples ();
  exit 0
