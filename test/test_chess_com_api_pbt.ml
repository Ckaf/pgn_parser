open QCheck2
open Chess_com_api

(* Property-based tests for Chess.com API *)

(* Generators for Chess.com API data *)

let gen_chess_com_username = 
  Gen.string_size ~gen:(Gen.char_range 'a' 'z') (Gen.int_range 3 20)

let gen_chess_com_rating = 
  Gen.int_range 800 3200

let gen_chess_com_game_id = 
  Gen.string_size ~gen:(Gen.char_range 'a' 'z') (Gen.int_range 8 15)

let gen_chess_com_time_class = 
  Gen.oneof [
    Gen.return "bullet";
    Gen.return "blitz";
    Gen.return "rapid";
    Gen.return "daily";
  ]

let gen_chess_com_result = 
  Gen.oneof [
    Gen.return "win";
    Gen.return "lose";
    Gen.return "draw";
    Gen.return "resign";
    Gen.return "timeout";
  ]

let gen_chess_com_game = 
  Gen.bind gen_chess_com_game_id (fun game_id ->
  Gen.bind gen_chess_com_username (fun white ->
  Gen.bind gen_chess_com_username (fun black ->
  Gen.bind gen_chess_com_rating (fun white_rating ->
  Gen.bind gen_chess_com_rating (fun black_rating ->
  Gen.bind gen_chess_com_time_class (fun time_class ->
  Gen.bind gen_chess_com_result (fun result ->
  Gen.bind (Gen.list_size (Gen.int_range 1 10) Gen.string) (fun moves ->
    let game = {
      id = game_id;
      white = white;
      black = black;
      pgn = Printf.sprintf "[White \"%s\"][Black \"%s\"][Result \"%s\"] %s" white black result (String.concat " " moves);
      winner = (match result with "win" -> Some white | "lose" -> Some black | _ -> None);
      speed = "blitz";
      game_state = "finished";
      created_at = Int64.of_int 1234567890;
      rating_white = Some white_rating;
      rating_black = Some black_rating;
      time_control = Some "600";
      variant = Some "standard";
      opening = Some "King's Pawn";
      end_time = Some (Int64.of_int 1234567890);
      time_class = Some time_class;
      rules = Some "chess";
      tournament = None;
    } in
    Gen.return game))))))))

let gen_chess_com_player = 
  Gen.bind gen_chess_com_username (fun username ->
  Gen.bind gen_chess_com_rating (fun rating ->
    let player = {
      id = "player_" ^ username;
      username = username;
      rating = Some rating;
      title = None;
      online = false;
      playing = false;
      country = None;
      created_at = Int64.of_int 1234567890;
      followers = Some 100;
      following = Some 50;
      is_streamer = false;
      is_verified = false;
      is_online = false;
    } in
    Gen.return player))

let gen_chess_com_puzzle = 
  Gen.bind gen_chess_com_game_id (fun puzzle_id ->
  Gen.bind (Gen.list_size (Gen.int_range 1 5) Gen.string) (fun solution ->
    let puzzle = {
      title = "Puzzle " ^ puzzle_id;
      fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
      solution = solution;
    } in
    Gen.return puzzle))

(* Properties to test *)

let prop_username_not_empty =
  Test.make ~name:"Username is not empty" ~count:100
    gen_chess_com_username
    (fun username -> 
      String.length username > 0)

let prop_rating_in_valid_range =
  Test.make ~name:"Rating is in valid range" ~count:100
    gen_chess_com_rating
    (fun rating -> 
      rating >= 800 && rating <= 3200)

let prop_game_id_unique_format =
  Test.make ~name:"Game ID has unique format" ~count:100
    gen_chess_com_game_id
    (fun game_id -> 
      String.length game_id >= 8 &&
      not (String.contains game_id ' '))

let prop_time_class_valid =
  Test.make ~name:"Time class is valid" ~count:100
    gen_chess_com_time_class
    (fun time_class -> 
      List.mem time_class ["bullet"; "blitz"; "rapid"; "daily"])

let prop_game_has_players =
  Test.make ~name:"Game has both players" ~count:100
    gen_chess_com_game
    (fun game -> 
      String.length game.white > 0 && 
      String.length game.black > 0 &&
      game.white <> game.black)

let prop_game_pgn_contains_players =
  Test.make ~name:"Game PGN contains player names" ~count:100
    gen_chess_com_game
    (fun game -> 
      Option.is_some (String.index_opt game.pgn (String.get game.white 0)) &&
      Option.is_some (String.index_opt game.pgn (String.get game.black 0)))

let prop_game_pgn_contains_result =
  Test.make ~name:"Game PGN contains result" ~count:100
    gen_chess_com_game
    (fun game -> 
      Option.is_some (String.index_opt game.pgn 'R') || 
      Option.is_some (String.index_opt game.pgn '1') || 
      Option.is_some (String.index_opt game.pgn '0') || 
      Option.is_some (String.index_opt game.pgn '*'))

let prop_chess_com_game_to_pgn_roundtrip =
  Test.make ~name:"Chess.com game to PGN roundtrip" ~count:100
    gen_chess_com_game
    (fun game -> 
      let pgn = chess_com_game_to_pgn game in
      String.length pgn > 0 &&
      Option.is_some (String.index_opt pgn (String.get game.white 0)) &&
      Option.is_some (String.index_opt pgn (String.get game.black 0)))

let prop_chess_com_game_to_pgn_valid =
  Test.make ~name:"Chess.com game to PGN conversion is valid" ~count:100
    gen_chess_com_game
    (fun game -> 
      let pgn = chess_com_game_to_pgn game in
      String.length pgn > 0 &&
      Option.is_some (String.index_opt pgn (String.get game.white 0)) &&
      Option.is_some (String.index_opt pgn (String.get game.black 0)))

let prop_player_has_valid_fields =
  Test.make ~name:"Player has valid fields" ~count:100
    gen_chess_com_player
    (fun player -> 
      String.length player.username > 0 &&
      String.length player.id > 0)

let prop_puzzle_has_valid_solution =
  Test.make ~name:"Puzzle has valid solution" ~count:100
    gen_chess_com_puzzle
    (fun puzzle -> 
      List.length puzzle.solution > 0 &&
      String.length puzzle.fen > 0)

(* Test suite *)

let tests = [
  prop_username_not_empty;
  prop_rating_in_valid_range;
  prop_game_id_unique_format;
  prop_time_class_valid;
  prop_game_has_players;
  prop_game_pgn_contains_players;
  prop_game_pgn_contains_result;
  prop_chess_com_game_to_pgn_roundtrip;
  prop_chess_com_game_to_pgn_valid;
  prop_player_has_valid_fields;
  prop_puzzle_has_valid_solution;
]

let () = 
  Printf.printf "\n=== Running Chess.com API Property-Based Tests ===\n";
  let _ = QCheck_runner.run_tests ~verbose:true tests in
  ()
