---
layout: default
title: Usage Examples
description: Comprehensive examples showing how to use PGN Parser for chess game analysis
---

# Usage Examples

## Basic PGN Parsing

### Simple Game

```ocaml
open Pgn_parser

let simple_game_example () =
  let pgn = "[Event \"Test Game\"]\n[Site \"Test Site\"]\n[Date \"2024.01.01\"]\n[White \"Alice\"]\n[Black \"Bob\"]\n\n1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Bxc6 dxc6 5. O-O" in
  
  match parse_game pgn with
  | Ok game ->
      Printf.printf "✅ Parsing successful!\n";
      Printf.printf "White: %s\n" (match game.info.white with Some w -> w.name | None -> "Unknown");
      Printf.printf "Black: %s\n" (match game.info.black with Some b -> b.name | None -> "Unknown");
      Printf.printf "Event: %s\n" (match game.info.event with Some e -> e | None -> "Unknown");
      Printf.printf "Number of moves: %d\n" (List.length game.moves);
      
      (* Show first 3 moves *)
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
      Printf.printf "❌ Parse error: ";
      pp_error Format.std_formatter e;
      Printf.printf "\n"
```

## Advanced Move Parsing

### Testing Various Move Types

```ocaml
open Pgn_parser

let advanced_moves_example () =
  Printf.printf "=== Advanced Move Parsing ===\n";
  
  let test_moves = [
    "e4";                    (* Basic pawn move *)
    "Nf3";                   (* Basic piece move *)
    "Bxe4";                  (* Capture *)
    "O-O";                   (* Kingside castling *)
    "O-O+";                  (* Castling with check *)
    "O-O-O#";                (* Queenside castling with checkmate *)
    "e8=Q";                  (* Promotion *)
    "e8=Q+";                 (* Promotion with check *)
    "exd8=Q#";               (* Capture promotion with checkmate *)
    "exd6e.p.";              (* En passant with explicit notation *)
    "exd6ep";                (* En passant with short notation *)
    "Rae1";                  (* File disambiguation *)
    "R1e1";                  (* Rank disambiguation *)
    "Ra1e1";                 (* Full disambiguation *)
    "Nbd7";                  (* Knight file disambiguation *)
    "N1d7";                  (* Knight rank disambiguation *)
    "Nb1d7";                 (* Knight full disambiguation *)
  ] in
  
  (* Parse each move *)
  List.iter (fun move_str ->
    match parse_simple_move move_str with
    | Ok move -> Printf.printf "✅ %s\n" move_str
    | Error e -> Printf.printf "❌ %s: %s\n" move_str (match e with InvalidMove s -> s | _ -> "Error")
  ) test_moves
```

### Error Handling

```ocaml
open Pgn_parser

let error_handling_example () =
  Printf.printf "=== Error Handling ===\n";
  
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
```

## Zobrist Hashing and Position Comparison

### Basic Zobrist Hashing Usage

```ocaml
open Pgn_parser

let zobrist_example () =
  Printf.printf "=== Zobrist Hashing ===\n";
  
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
```

### Position Comparison

```ocaml
open Pgn_parser

let position_comparison_example () =
  Printf.printf "=== Position Comparison ===\n";
  
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
```

## Board Visualization

### Basic Visualization

```ocaml
open Pgn_parser

let board_visualization_example () =
  Printf.printf "=== Board Visualization ===\n\n";
  
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
       | None -> Printf.printf "Final position not available\n");
      
  | Error e ->
      Printf.printf "Error parsing PGN: %s\n" (match e with
        | InvalidMove s -> "Invalid move: " ^ s
        | InvalidTag s -> "Invalid tag: " ^ s
        | InvalidFormat s -> "Invalid format: " ^ s
        | UnexpectedEnd s -> "Unexpected end: " ^ s)
```

## API Integration

### Lichess API

```ocaml
open Lwt.Syntax
open Pgn_parser
open Lichess_api

let lichess_api_example () =
  Printf.printf "=== Lichess API Integration ===\n";
  
  let%lwt game_opt = fetch_random_game () in
  match game_opt with
  | Some game ->
      Printf.printf "Game: %s vs %s\n" game.white game.black;
      Printf.printf "PGN length: %d characters\n" (String.length game.pgn);
      
      (* Parse PGN *)
      match parse_game game.pgn with
      | Ok parsed_game ->
          Printf.printf "Parsed %d moves\n" (List.length parsed_game.moves)
      | Error e -> Printf.printf "Parse error\n"
  | None -> Printf.printf "No game found\n"
```

### Chess.com API

```ocaml
open Lwt.Syntax
open Pgn_parser
open Chess_com_api

let chess_com_api_example () =
  Printf.printf "=== Chess.com API Integration ===\n";
  
  let%lwt games = fetch_player_games "hikaru" ~max_games:5 () in
  List.iter (fun game ->
    Printf.printf "Game: %s vs %s (%s)\n" game.white game.black game.speed
  ) games;
  
  (* Get player statistics *)
  let%lwt stats_opt = get_player_stats "hikaru" in
  match stats_opt with
  | Some stats ->
      Printf.printf "Win rate: %.1f%%\n" (stats.win_rate *. 100.0)
  | None -> Printf.printf "Stats not available\n"
```

## Working with Multiple Games

### Parsing Document with Multiple Games

```ocaml
open Pgn_parser

let multiple_games_example () =
  Printf.printf "=== Multiple Games ===\n";
  
  let pgn_document = {|
[Event "Game 1"]
[White "Alice"]
[Black "Bob"]
1. e4 e5 1-0

[Event "Game 2"]
[White "Charlie"]
[Black "David"]
1. d4 d5 2. c4 1/2-1/2
|} in
  
  match parse_document pgn_document with
  | Ok games ->
      Printf.printf "Found %d games\n" (List.length games);
      List.iteri (fun i game ->
        Printf.printf "Game %d: %s vs %s\n" (i + 1)
          (match game.info.white with Some w -> w.name | None -> "Unknown")
          (match game.info.black with Some b -> b.name | None -> "Unknown")
      ) games
  | Error e ->
      Printf.printf "Document parse error: ";
      pp_error Format.std_formatter e;
      Printf.printf "\n"
```

## Game Analysis

### Game Statistics

```ocaml
open Pgn_parser

let game_analysis_example () =
  Printf.printf "=== Game Analysis ===\n";
  
  let pgn = "[Event \"Test Game\"]\n[White \"Alice\"]\n[Black \"Bob\"]\n\n1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Bxc6 dxc6 5. O-O Be7 6. Re1 b5 7. Bb3 d6 8. c3 O-O 9. h3 Nb8 10. d4 Nbd7 11. Nc3 Bb7 12. Bc2 Re8 13. Nf1 Bf8 14. Ng3 g6 15. a4 c5 16. d5 c4 17. Bg5 h6 18. Be3 Nc5 19. Qd2 Kh7 20. Rae1 Qd7 21. Bg5 Bg7 22. f3 Rae8 23. Kh2 Qf7 24. Nf1 f5 25. exf5 gxf5 26. f4 exf4 27. Bxf4 Qe7 28. Qe2 Qe5 29. Qxe5 dxe5 30. Be3 f4 31. Bf2 e4 32. Ng1 Bc8 33. N1e2 Bd7 34. b4 cxb3 35. Bxb3 Bc5 36. Nc3 Bb6 37. Ncd5 Bxd5 38. Nxd5 Re5 39. c4 bxc4 40. Bxc4 Rg5 41. Bf1 Rxg2+ 42. Kxg2 e3+ 43. Kg1 e2 44. Bxe2 f3 45. Bxf3 Nxf3+ 46. Kf2 Nxd2 47. Nc7 Nxf1 48. Kf1 Rf8+ 49. Ke1 Rf2 50. Kd1 Rd2+ 51. Kc1 Rd1#" in
  
  match parse_game pgn with
  | Ok game ->
      let total_moves = List.length game.moves in
      let white_moves = List.filter (fun move -> move.white_move <> None) game.moves in
      let black_moves = List.filter (fun move -> move.black_move <> None) game.moves in
      
      Printf.printf "Total moves: %d\n" total_moves;
      Printf.printf "White moves: %d\n" (List.length white_moves);
      Printf.printf "Black moves: %d\n" (List.length black_moves);
      
      (* Count move types *)
      let rec count_move_types moves acc =
        match moves with
        | [] -> acc
        | move :: rest ->
            let acc = match move.white_move with
              | Some (Normal _) -> {acc with normal = acc.normal + 1}
              | Some (Capture _) -> {acc with captures = acc.captures + 1}
              | Some (Castle _) -> {acc with castles = acc.castles + 1}
              | Some (EnPassant _) -> {acc with en_passant = acc.en_passant + 1}
              | Some (Promotion _) -> {acc with promotions = acc.promotions + 1}
              | _ -> acc
            in
            let acc = match move.black_move with
              | Some (Normal _) -> {acc with normal = acc.normal + 1}
              | Some (Capture _) -> {acc with captures = acc.captures + 1}
              | Some (Castle _) -> {acc with castles = acc.castles + 1}
              | Some (EnPassant _) -> {acc with en_passant = acc.en_passant + 1}
              | Some (Promotion _) -> {acc with promotions = acc.promotions + 1}
              | _ -> acc
            in
            count_move_types rest acc
      in
      
      let move_stats = count_move_types game.moves {
        normal = 0;
        captures = 0;
        castles = 0;
        en_passant = 0;
        promotions = 0;
      } in
      
      Printf.printf "\nMove statistics:\n";
      Printf.printf "Normal moves: %d\n" move_stats.normal;
      Printf.printf "Captures: %d\n" move_stats.captures;
      Printf.printf "Castles: %d\n" move_stats.castles;
      Printf.printf "En passant: %d\n" move_stats.en_passant;
      Printf.printf "Promotions: %d\n" move_stats.promotions;
      
  | Error e ->
      Printf.printf "Parse error: ";
      pp_error Format.std_formatter e;
      Printf.printf "\n"
```

## Running Examples

All examples can be run using demo programs:

```bash
# Basic PGN parsing
dune exec examples/simple_demo

# Board visualization
dune exec examples/board_demo

# Zobrist hashing
dune exec examples/zobrist_demo

# Lichess API
dune exec examples/lichess_demo

# Chess.com API
dune exec examples/chess_com_demo

# PGN parsing
dune exec examples/pgn_demo
```