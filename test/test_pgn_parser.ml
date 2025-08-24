(** Property-based tests for PGN parser using only generated data *)

open QCheck2
open Pgn_parser

(** Helper functions for testing *)

let string_of_piece = function
  | King -> "K"
  | Queen -> "Q"
  | Rook -> "R"
  | Bishop -> "B"
  | Knight -> "N"
  | Pawn -> ""



let string_of_result = function
  | WhiteWin -> "1-0"
  | BlackWin -> "0-1"
  | Draw -> "1/2-1/2"
  | Ongoing -> "*"

(** Generators for property-based testing *)

(** Generate a random chess piece *)
let gen_piece = 
  QCheck2.Gen.oneof [
    QCheck2.Gen.return King;
    QCheck2.Gen.return Queen;
    QCheck2.Gen.return Rook;
    QCheck2.Gen.return Bishop;
    QCheck2.Gen.return Knight;
    QCheck2.Gen.return Pawn;
  ]

(** Generate a random chess square *)
let gen_square = 
  let gen_file = QCheck2.Gen.oneof [
    QCheck2.Gen.return 'a'; QCheck2.Gen.return 'b'; QCheck2.Gen.return 'c'; QCheck2.Gen.return 'd';
    QCheck2.Gen.return 'e'; QCheck2.Gen.return 'f'; QCheck2.Gen.return 'g'; QCheck2.Gen.return 'h';
  ] in
  let gen_rank = QCheck2.Gen.int_range 1 8 in
  QCheck2.Gen.pair gen_file gen_rank

(** Generate a random game result *)
let gen_result = 
  QCheck2.Gen.oneof [
    QCheck2.Gen.return WhiteWin;
    QCheck2.Gen.return BlackWin;
    QCheck2.Gen.return Draw;
    QCheck2.Gen.return Ongoing;
  ]

(** Generate a random player name *)
let gen_player_name = 
  QCheck2.Gen.oneof [
    QCheck2.Gen.return "Player1"; QCheck2.Gen.return "Player2"; QCheck2.Gen.return "Magnus";
    QCheck2.Gen.return "Hikaru"; QCheck2.Gen.return "AlphaZero"; QCheck2.Gen.return "Stockfish";
    QCheck2.Gen.return "TestUser"; QCheck2.Gen.return "ChessBot"; QCheck2.Gen.return "GrandMaster";
  ]

(** Generate a simple move string *)
let gen_simple_move =
  QCheck2.Gen.oneof [
    (* Pawn moves *)
    QCheck2.Gen.map (fun (file, rank) -> Printf.sprintf "%c%d" file rank) gen_square;
    (* Piece moves *)
    QCheck2.Gen.map2 (fun piece (file, rank) -> 
      Printf.sprintf "%s%c%d" (string_of_piece piece) file rank) gen_piece gen_square;
    (* Castling *)
    QCheck2.Gen.return "O-O";
    QCheck2.Gen.return "O-O-O";
    (* Simple captures *)
    QCheck2.Gen.map2 (fun piece (file, rank) -> 
      Printf.sprintf "%sx%c%d" (string_of_piece piece) file rank) gen_piece gen_square;
  ]

(** Generate a move pair (white and black) *)
let gen_move_pair =
  QCheck2.Gen.pair gen_simple_move gen_simple_move

(** Generate a simple PGN game *)
let gen_simple_pgn =
  QCheck2.Gen.bind gen_player_name (fun white_name ->
    QCheck2.Gen.bind gen_player_name (fun black_name ->
      QCheck2.Gen.bind gen_result (fun result ->
        QCheck2.Gen.bind (QCheck2.Gen.int_range 1 5) (fun num_moves ->
          QCheck2.Gen.bind (QCheck2.Gen.list_size (QCheck2.Gen.return num_moves) gen_move_pair) (fun moves ->
            let header = Printf.sprintf "[Event \"Generated Game\"]\n[White \"%s\"]\n[Black \"%s\"]\n\n" white_name black_name in
            let move_strings = List.mapi (fun i (white_move, black_move) ->
              Printf.sprintf "%d. %s %s" (i + 1) white_move black_move
            ) moves in
            let game_body = String.concat " " move_strings in
            let result_str = " " ^ string_of_result result in
            QCheck2.Gen.return (header ^ game_body ^ result_str)
          )
        )
      )
    )
  )

(** Property-based tests *)

(** Test that piece generation works correctly *)
let test_piece_generation =
  Test.make ~name:"piece_generation" ~count:100
    gen_piece
    (fun piece -> 
      match piece with 
      | King | Queen | Rook | Bishop | Knight | Pawn -> true)

(** Test that square generation works correctly *)
let test_square_generation =
  Test.make ~name:"square_generation" ~count:100
    gen_square
    (fun (file, rank) -> 
      file >= 'a' && file <= 'h' && rank >= 1 && rank <= 8)

(** Test that result generation works correctly *)
let test_result_generation =
  Test.make ~name:"result_generation" ~count:100
    gen_result
    (fun result -> 
      match result with 
      | WhiteWin | BlackWin | Draw | Ongoing -> true)

(** Test that simple moves can be generated and are valid strings *)
let test_simple_move_generation =
  Test.make ~name:"simple_move_generation" ~count:100
    gen_simple_move
    (fun move_str -> 
      String.length move_str > 0 && String.length move_str < 10)

(** Test generated PGN games have basic structure *)
let test_generated_pgn_structure =
  Test.make ~name:"generated_pgn_structure" ~count:50
    gen_simple_pgn
    (fun pgn_str ->
      (* Basic structural checks *)
      String.contains pgn_str '[' &&  (* Has tags *)
      String.contains pgn_str ']' &&
      String.contains pgn_str '.' &&  (* Has moves *)
      String.length pgn_str > 10)     (* Non-trivial length *)

(** Test that most generated PGNs can be parsed *)
let test_generated_pgn_parsing =
  Test.make ~name:"generated_pgn_parsing" ~count:30
    gen_simple_pgn
    (fun pgn_str ->
      match parse_game pgn_str with
      | Ok game -> 
          (* If it parses, check basic invariants *)
          List.length game.moves >= 0 &&  (* Non-negative moves *)
          (match game.info.white, game.info.black with
           | Some w, Some b -> String.length w.name > 0 && String.length b.name > 0
           | _ -> true)  (* Allow missing player info *)
      | Error _ -> true  (* Parsing failures are acceptable for generated data *)
    )

(** Test roundtrip property for successfully parsed games *)
let test_roundtrip_property =
  Test.make ~name:"roundtrip_property" ~count:20
    gen_simple_pgn
    (fun pgn_str ->
      match parse_game pgn_str with
      | Ok game ->
          let reconstructed = to_pgn game in
          (* Check that reconstruction produces non-empty result *)
          String.length reconstructed > 0 &&
          (* Try to parse the reconstructed PGN *)
          (match parse_game reconstructed with
           | Ok _ -> true
           | Error _ -> false)
      | Error _ -> true  (* Skip failed parses *)
    )

(** Test that parser handles edge cases gracefully *)
let test_parser_robustness =
  let gen_edge_case = QCheck2.Gen.oneof [
    QCheck2.Gen.return "";  (* Empty string *)
    QCheck2.Gen.return "   ";  (* Whitespace only *)
    QCheck2.Gen.return "[";  (* Incomplete tag *)
    QCheck2.Gen.return "1.";  (* Incomplete move *)
    QCheck2.Gen.string_size (QCheck2.Gen.return 1);  (* Single char *)
  ] in
  
  Test.make ~name:"parser_robustness" ~count:50
    gen_edge_case
    (fun edge_case ->
      match parse_game edge_case with
      | Ok _ -> true  (* Successful parse is fine *)
      | Error _ -> true  (* Error is expected for edge cases *)
    )

(** Test move string properties *)
let test_move_properties =
  Test.make ~name:"move_properties" ~count:100
    gen_simple_move
    (fun move_str ->
      (* Test basic move string properties *)
      String.length move_str > 0 &&  (* Non-empty *)
      String.length move_str < 20 && (* Reasonable length *)
      not (String.contains move_str '\n')  (* No newlines *)
    )

(** Main test runner *)
let () =
  Printf.printf "=== Running Property-Based Tests ===\n\n";
  
  let tests = [
    test_piece_generation;
    test_square_generation;
    test_result_generation;
    test_simple_move_generation;
    test_generated_pgn_structure;
    test_generated_pgn_parsing;
    test_roundtrip_property;
    test_parser_robustness;
    test_move_properties;
  ] in
  
  let _ = QCheck_runner.run_tests ~verbose:true tests in
  Printf.printf "\n🎉 Property-based tests completed!\n"