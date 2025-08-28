open QCheck2
open Lichess_api

(* Property-based tests for Lichess API *)

(* Generators for Lichess API data *)

let gen_lichess_game_id = 
  Gen.string_size ~gen:Gen.char (Gen.int_range 8 12)

let gen_lichess_username = 
  Gen.string_size ~gen:(Gen.char_range 'a' 'z') (Gen.int_range 3 15)

let gen_lichess_rating = 
  Gen.int_range 800 3200

let gen_lichess_time_control = 
  Gen.oneof [
    Gen.return "60+0";  (* Bullet *)
    Gen.return "180+0"; (* Blitz *)
    Gen.return "600+0"; (* Rapid *)
    Gen.return "1800+0"; (* Classical *)
  ]

let gen_lichess_result = 
  Gen.oneof [
    Gen.return "1-0";   (* White wins *)
    Gen.return "0-1";   (* Black wins *)
    Gen.return "1/2-1/2"; (* Draw *)
    Gen.return "*";     (* Ongoing *)
  ]

let gen_lichess_game = 
  Gen.bind gen_lichess_game_id (fun game_id ->
  Gen.bind gen_lichess_username (fun white ->
  Gen.bind gen_lichess_username (fun black ->
  Gen.bind gen_lichess_rating (fun white_rating ->
  Gen.bind gen_lichess_rating (fun black_rating ->
  Gen.bind gen_lichess_time_control (fun time_control ->
  Gen.bind gen_lichess_result (fun result ->
  Gen.bind (Gen.list_size (Gen.int_range 1 10) Gen.string) (fun moves ->
    let game = {
      id = game_id;
      white = white;
      black = black;
      pgn = Printf.sprintf "[White \"%s\"][Black \"%s\"][Result \"%s\"] %s" white black result (String.concat " " moves);
      winner = (match result with "1-0" -> Some white | "0-1" -> Some black | _ -> None);
      speed = "blitz";
      status = "finished";
      created_at = Int64.of_int 1234567890;
      rating_white = Some white_rating;
      rating_black = Some black_rating;
      time_control = Some time_control;
      variant = Some "standard";
      opening = Some "King's Pawn";
    } in
    Gen.return game))))))))

(* Properties to test *)

let prop_game_id_not_empty =
  Test.make ~name:"Game ID is not empty" ~count:100
    gen_lichess_game_id
    (fun game_id -> 
      String.length game_id > 0)

let prop_username_valid_format =
  Test.make ~name:"Username has valid format" ~count:100
    gen_lichess_username
    (fun username -> 
      String.length username >= 3 && 
      String.length username <= 15 &&
      not (String.contains username ' '))

let prop_rating_in_range =
  Test.make ~name:"Rating is in valid range" ~count:100
    gen_lichess_rating
    (fun rating -> 
      rating >= 800 && rating <= 3200)

let prop_game_has_players =
  Test.make ~name:"Game has both players" ~count:100
    gen_lichess_game
    (fun game -> 
      String.length game.white > 0 && 
      String.length game.black > 0 &&
      game.white <> game.black)

let prop_game_pgn_contains_players =
  Test.make ~name:"Game PGN contains player names" ~count:100
    gen_lichess_game
    (fun game -> 
      Option.is_some (String.index_opt game.pgn (String.get game.white 0)) &&
      Option.is_some (String.index_opt game.pgn (String.get game.black 0)))

let prop_game_pgn_contains_result =
  Test.make ~name:"Game PGN contains result" ~count:100
    gen_lichess_game
    (fun game -> 
      Option.is_some (String.index_opt game.pgn '1') || Option.is_some (String.index_opt game.pgn '0') || Option.is_some (String.index_opt game.pgn '*'))

let prop_lichess_game_to_pgn_roundtrip =
  Test.make ~name:"Lichess game to PGN roundtrip" ~count:100
    gen_lichess_game
    (fun game -> 
      let pgn = lichess_game_to_pgn game in
      String.length pgn > 0 &&
      Option.is_some (String.index_opt pgn (String.get game.white 0)) &&
      Option.is_some (String.index_opt pgn (String.get game.black 0)))

let prop_lichess_game_to_pgn_valid =
  Test.make ~name:"Lichess game to PGN conversion is valid" ~count:100
    gen_lichess_game
    (fun game -> 
      let pgn = lichess_game_to_pgn game in
      String.length pgn > 0 &&
      Option.is_some (String.index_opt pgn (String.get game.white 0)) &&
      Option.is_some (String.index_opt pgn (String.get game.black 0)))

(* Test suite *)

let tests = [
  prop_game_id_not_empty;
  prop_username_valid_format;
  prop_rating_in_range;
  prop_game_has_players;
  prop_game_pgn_contains_players;
  prop_game_pgn_contains_result;
  prop_lichess_game_to_pgn_roundtrip;
  prop_lichess_game_to_pgn_valid;
]

let () = 
  Printf.printf "\n=== Running Lichess API Property-Based Tests ===\n";
  let _ = QCheck_runner.run_tests ~verbose:true tests in
  ()
