# PGN Parser

[![CI/CD](https://github.com/ckaf/pgn_parser/actions/workflows/ci.yml/badge.svg)](https://github.com/ckaf/pgn_parser/actions/workflows/ci.yml)
[![Quick Check](https://github.com/ckaf/pgn_parser/actions/workflows/quick-check.yml/badge.svg)](https://github.com/ckaf/pgn_parser/actions/workflows/quick-check.yml)
[![Compatibility](https://github.com/ckaf/pgn_parser/actions/workflows/compatibility.yml/badge.svg)](https://github.com/ckaf/pgn_parser/actions/workflows/compatibility.yml)

A PGN (Portable Game Notation) parser for chess games written in OCaml. This parser can parse chess games from platforms like Lichess and other chess websites.

## Features

- **PGN Parsing**: Parse PGN game metadata (players, event, site, date, etc.)
- **Move Parsing**: Parse chess moves including:
  - Normal piece moves (e4, Nf3, Bxe4)
  - Captures (exd4, Nxd4, Bxf7)
  - Castling (O-O, O-O-O) with check/checkmate (O-O+, O-O#)
  - Promotions (g8=Q, a1=R#) with check/checkmate (e8=Q+, e8=Q#)
  - En Passant captures (exd6, exd6e.p., exd6ep) with validation
  - Complex disambiguation (Rae1, R1e1, Ra1e1, Nbd7, N1d7)
  - Edge case handling for all move types
  - Invalid move detection and validation
  - Game results (1-0, 0-1, 1/2-1/2, *)
  - **Unfinished games** with ongoing status
- **API Integration**: 
  - **Lichess API**: Fetch and parse real games from Lichess
    - Get detailed player statistics with ratings and performance data
    - Fetch ongoing games with real-time data
    - Comprehensive JSON parsing for all API responses
  - **Chess.com API**: Fetch games, player stats, tournaments, and daily puzzles
    - Fetch games by player username with filtering and pagination
    - Fetch ongoing games from top players and leaderboards
    - Search games with multiple filters (player, variant, speed, rated)
    - Fetch individual games by ID with complete metadata
    - Real-time data from Chess.com monthly archives
- **Advanced Features**:
  - **Board Tracking**: Maintain board state throughout the game
  - **Zobrist Hashing**: Fast position comparison using Zobrist hashing
  - **Position Comparison**: Efficient comparison of chess positions
  - **Unfinished Games Support**: Handle ongoing and incomplete games
- **Testing**: Comprehensive property-based testing with QCheck2
- **Round-trip parsing**: Parse -> reconstruct -> parse validation

## Installation

### Prerequisites

- OCaml (4.14 or later)
- OPAM (OCaml package manager)
- Dune build system

### Setup

1. Clone the repository:
```bash
git clone https://github.com/Ckaf/pgn_parser.git
cd pgn_parser
```

2. Install dependencies:
```bash
opam install qcheck
```

3. Build the project:
```bash
dune build
```

## Usage

### Running Tests

Run all tests:
```bash
dune runtest
```

This will run:
- Property-based tests with QCheck2
- Zobrist hash tests
- API integration tests
- Advanced move parsing tests
- Unfinished games tests

### Running Examples

Run various demo programs:
```bash
# Basic PGN parsing demo
dune exec examples/simple_demo

# Board visualization demo
dune exec examples/board_demo

# Zobrist hash demo
dune exec examples/zobrist_demo

# Lichess API demo
dune exec examples/lichess_demo

# Chess.com API demo
dune exec examples/chess_com_demo

# PGN parsing demo
dune exec examples/pgn_demo
```

### Running Tests

Run all tests:
```bash
dune runtest
```

Run specific test suites:
```bash
# Property-based tests
dune exec test/test_pgn_parser

# Zobrist hash tests
dune exec test/test_zobrist

# Advanced move parsing tests
dune exec test/test_advanced_moves

# Unfinished games tests
dune exec test/test_unfinished_games

# Lichess API tests (online)
dune exec test/test_lichess_api

# Lichess API tests (offline)
dune exec test/test_lichess_api_offline

# Chess.com API tests (online)
dune exec test/test_chess_com_api

# Chess.com API tests (offline)
dune exec test/test_chess_com_api_offline

# Integration tests
dune exec test/test_integration
```

## Examples

### Basic PGN Parsing

```ocaml
open Pgn_parser

let pgn = "[Event \"Test Game\"]\n[White \"Player1\"]\n[Black \"Player2\"]\n\n1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 7. Bb3 d6 8. c3 O-O 9. h3 Nb8 10. d4 Nbd7 11. Nc3 Bb7 12. Bc2 Re8 13. Nf1 Bf8 14. Ng3 g6 15. a4 c5 16. d5 c4 17. Bg5 h6 18. Be3 Nc5 19. Qd2 Kh7 20. Rae1 Qd7 21. Bg5 Bg7 22. f3 Rae8 23. Kh2 Qf7 24. Nf1 f5 25. exf5 gxf5 26. f4 exf4 27. Bxf4 Qe7 28. Qe2 Qe5 29. Qxe5 dxe5 30. Be3 f4 31. Bf2 e4 32. Ng1 Bc8 33. N1e2 Bd7 34. b4 cxb3 35. Bxb3 Bc5 36. Nc3 Bb6 37. Ncd5 Bxd5 38. Nxd5 Re5 39. c4 bxc4 40. Bxc4 Rg5 41. Bf1 Rxg2+ 42. Kxg2 e3+ 43. Kg1 e2 44. Bxe2 f3 45. Bxf3 Nxf3+ 46. Kf2 Nxd2 47. Nc7 Nxf1 48. Kf1 Rf8+ 49. Ke1 Rf2 50. Kd1 Rd2+ 51. Kc1 Rd1#"

match parse_game pgn with
| Ok game ->
    Printf.printf "White: %s\n" (match game.info.white with Some w -> w.name | None -> "Unknown");
    Printf.printf "Black: %s\n" (match game.info.black with Some b -> b.name | None -> "Unknown");
    Printf.printf "Moves: %d\n" (List.length game.moves);
    Printf.printf "Result: %s\n" (match game.info.result with 
      | Some r -> (match r with WhiteWin -> "1-0" | BlackWin -> "0-1" | Draw -> "1/2-1/2" | Ongoing -> "*")
      | None -> "None")
| Error e ->
    Printf.printf "Parse error: %s\n" (match e with
      | InvalidMove s -> "Invalid move: " ^ s
      | InvalidTag s -> "Invalid tag: " ^ s
      | InvalidFormat s -> "Invalid format: " ^ s
      | UnexpectedEnd s -> "Unexpected end: " ^ s)
```

### Advanced Move Parsing

The parser supports complex chess moves including:

```ocaml
open Pgn_parser

(* Test various move types *)
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
]

(* Parse each move *)
List.iter (fun move_str ->
  match parse_simple_move move_str with
  | Ok move -> Printf.printf "✅ %s\n" move_str
  | Error e -> Printf.printf "❌ %s: %s\n" move_str (match e with InvalidMove s -> s | _ -> "Error")
) test_moves
```

### Error Handling

The parser provides robust error handling for invalid moves:

```ocaml
open Pgn_parser

(* Test invalid moves *)
let invalid_moves = [
  "";                      (* Empty move *)
  "X";                     (* Invalid piece *)
  "i1";                    (* Invalid file *)
  "a9";                    (* Invalid rank *)
  "K";                     (* Incomplete move *)
  "O-O-O-O";               (* Invalid castling *)
  "e8=P";                  (* Invalid promotion piece *)
  "e8=K";                  (* Invalid promotion piece *)
]

(* All should fail validation *)
List.iter (fun move_str ->
  match parse_simple_move move_str with
  | Ok _ -> Printf.printf "⚠️  %s (unexpectedly succeeded)\n" move_str
  | Error _ -> Printf.printf "✅ %s (correctly failed)\n" move_str
) invalid_moves
```

## Zobrist Hashing and Position Comparison

The parser now includes Zobrist hashing for efficient position comparison:

```ocaml
open Pgn_parser

(* Create starting position *)
let board = create_starting_position ()
let hash = calculate_zobrist_hash board

(* Apply a move *)
let e4_move = Normal (Pawn, ('e', 2), ('e', 4))
let new_board = apply_move_to_board board e4_move true
let new_hash = calculate_zobrist_hash new_board

(* Compare positions *)
let positions_are_equal = positions_equal board new_board
let hashes_are_equal = zobrist_equal hash new_hash

(* Each move in parsed games includes board state and Zobrist hash *)
match parse_game pgn with
| Ok game ->
    List.iter (fun move ->
      match move.zobrist_after_white with
      | Some hash -> Printf.printf "Position hash: %Ld\n" hash
      | None -> ()
    ) game.moves
| Error _ -> ()
```

## Board Visualization

The parser includes functions for visualizing chess positions:

```ocaml
open Pgn_parser

(* Print a board position *)
let board = create_starting_position ()
print_board board

(* Get board as string *)
let board_str = board_to_string board

(* Get board position after specific move *)
let board_after_e4 = get_board_after_move game.moves 1 true

(* Get final board position *)
let final_board = get_final_board game.moves

(* Visualize entire game progression *)
let visualization = visualize_game_progression game
```

Run the examples:
```bash
# Basic PGN parsing demo
dune exec examples/pgn_demo

# Board visualization demo
dune exec examples/board_demo

# Zobrist hash demo
dune exec examples/zobrist_demo

# Lichess API demo
dune exec examples/lichess_demo

## API Integration

### Lichess API Integration

The parser includes integration with the Lichess API to fetch and parse real chess games:
```

```ocaml
open Lwt.Syntax
open Pgn_parser
open Lichess_api

(* Fetch a random game from Lichess *)
let* game_opt = fetch_random_game () in
match game_opt with
| Some game ->
    Printf.printf "Game: %s vs %s\n" game.white game.black;
    Printf.printf "PGN length: %d characters\n" (String.length game.pgn);
    
    (* Parse the PGN *)
    match parse_game game.pgn with
    | Ok parsed_game ->
        Printf.printf "Parsed %d moves\n" (List.length parsed_game.moves)
    | Error e -> Printf.printf "Parse error\n"
| None -> Printf.printf "No game found\n"
```

### Chess.com API Integration

The parser also includes integration with the Chess.com API:

```ocaml
open Lwt.Syntax
open Pgn_parser
open Chess_com_api

(* Fetch player games from Chess.com *)
let* games = fetch_player_games "hikaru" ~max_games:5 () in
List.iter (fun game ->
  Printf.printf "Game: %s vs %s (%s)\n" game.white game.black game.speed
) games

(* Get player statistics *)
let* stats_opt = get_player_stats "hikaru" in
match stats_opt with
| Some stats ->
    Printf.printf "Win rate: %.1f%%\n" (stats.win_rate *. 100.0)
| None -> Printf.printf "Stats not available\n"
```

### API Features

**Lichess API:**
- Fetch random games from Lichess
- Parse real PGN data from live games
- Extract game metadata (players, events, results)
- Support for multiple game formats (blitz, rapid, classical)
- Fetch ongoing games and player statistics

**Chess.com API:**
- Fetch player games and archives
- Get player statistics and ratings
- Access tournament information
- Fetch daily puzzles
- Get leaderboards and club information

## Supported PGN Features

### Game Metadata
- Event, Site, Date, Round
- White and Black player names
- Game result
- ECO codes and openings
- Time control and termination

### Limitations

The current implementation has some limitations:
- Limited support for complex move annotations
- No support for comments or NAG codes
- Basic move parsing (doesn't validate chess rules)
- No support for FEN position parsing
- No support for move annotations like "!", "?", "!!", "??", etc.

## Testing

The project uses comprehensive testing approaches:

### 1. Property-Based Testing (PBT)
Uses QCheck2 to generate random chess data and test parser properties:
- **Generators**: Random PGN games, chess pieces, squares, moves
- **Properties**: Round-trip parsing, structure validation, error handling
- **Coverage**: Various PGN formats and edge cases

### 2. Advanced Move Testing
Comprehensive testing of complex chess moves:
- **Disambiguation**: File, rank, and full disambiguation (Rae1, R1e1, Ra1e1)
- **En Passant**: Standard and explicit notation (exd6, exd6e.p., exd6ep)
- **Promotions**: All promotion types with check/checkmate (e8=Q, e8=Q+, e8=Q#)
- **Castling**: All castling variants with check/checkmate (O-O+, O-O#)
- **Edge Cases**: Boundary conditions and unusual but valid moves
- **Error Validation**: Proper rejection of invalid moves and coordinates

### 3. API Integration Testing
Tests with real chess games from multiple platforms:
- **Lichess API**: Real games from Lichess platform
- **Chess.com API**: Real games from Chess.com platform
- **Edge Cases**: Complex positions and move sequences
- **Integration**: API connectivity and data processing

### 4. Specialized Test Suites
- **Zobrist Hash Tests**: Position comparison and hash validation
- **Unfinished Games Tests**: Handling of ongoing and incomplete games
- **Advanced Move Tests**: Comprehensive move parsing and validation
- **Offline Tests**: Mock data testing without network dependencies
- **Integration Tests**: End-to-end functionality testing

### 4. Test Coverage
- **No hardcoded test data** - all tests use either:
  - Generated random data (PBT)
  - Live data from APIs
  - Mock data for offline testing
- **Comprehensive move testing** - covers all supported move types
- **Edge case validation** - tests invalid moves and error conditions

Run all tests:
```bash
dune runtest                          # All tests
dune exec test/test_pgn_parser        # Property-based tests
dune exec test/test_zobrist           # Zobrist hash tests
dune exec test/test_advanced_moves    # Advanced move parsing tests
dune exec test/test_unfinished_games  # Unfinished games tests
```

## CI/CD

The project uses GitHub Actions for continuous integration and deployment:

### Workflows
- **CI/CD** (`ci.yml`): Main workflow for testing, linting, security checks, and releases
- **Quick Check** (`quick-check.yml`): Fast tests for feature branches
- **Compatibility** (`compatibility.yml`): Tests with different OCaml versions
- **Performance** (`performance.yml`): Performance and memory usage checks
- **Cache** (`cache.yml`): OPAM dependency caching

### Features
- ✅ **Multi-version testing**: OCaml 4.14, 5.0, 5.1
- ✅ **Code formatting**: Automatic format checking with `ocamlformat`
- ✅ **Security checks**: Vulnerability scanning and security-focused tests
- ✅ **Documentation**: Automatic documentation generation
- ✅ **Releases**: Automated releases on tags
- ✅ **Dependency updates**: Weekly updates via Dependabot

## Future Improvements

- [ ] Full move validation (chess rules)
- [ ] Support for comments and annotations
- [ ] FEN position parsing
- [ ] More comprehensive error messages
- [ ] Support for multiple games in one file
- [ ] Move annotation support (!, ?, !!, ??, etc.)

## License

This project is licensed under the MIT License.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## Acknowledgments

- Inspired by the need to parse chess games from Lichess
- Uses QCheck2 for property-based testing
- Built with OCaml and Dune
