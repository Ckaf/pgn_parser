---
layout: default
title: PGN Parser Documentation
description: Comprehensive PGN (Portable Game Notation) parser for chess games written in OCaml
---

# PGN Parser - Documentation

[![CI/CD](https://github.com/ckaf/pgn_parser/actions/workflows/ci.yml/badge.svg)](https://github.com/ckaf/pgn_parser/actions/workflows/ci.yml)
[![Quick Check](https://github.com/ckaf/pgn_parser/actions/workflows/quick-check.yml/badge.svg)](https://github.com/ckaf/pgn_parser/actions/workflows/quick-check.yml)
[![Compatibility](https://github.com/ckaf/pgn_parser/actions/workflows/compatibility.yml/badge.svg)](https://github.com/ckaf/pgn_parser/actions/workflows/compatibility.yml)

[![OPAM Package](https://img.shields.io/badge/OPAM%20Package-pgn__parser-green.svg?logo=ocaml)](https://opam.ocaml.org/packages/pgn_parser/)
[![OPAM Package](https://img.shields.io/badge/OPAM%20Package-lichess__api-red.svg?logo=ocaml)](https://opam.ocaml.org/packages/lichess_api/)
[![OPAM Package](https://img.shields.io/badge/OPAM%20Package-chess__com__api-blue.svg?logo=ocaml)](https://opam.ocaml.org/packages/chess_com_api/)

## Overview

**PGN Parser** is a comprehensive parser for chess games in PGN (Portable Game Notation) format, written in OCaml. The library provides powerful tools for parsing, analyzing, and visualizing chess games with support for integration with popular chess platforms.

## Key Features

### 🎯 PGN Parsing
- **Game metadata**: parsing player information, events, dates, and results
- **Moves**: full support for all types of chess moves
- **Results**: handling game results (1-0, 0-1, 1/2-1/2, *)
- **Unfinished games**: support for ongoing and incomplete games

### 🏃‍♂️ Move Types
- **Normal moves**: e4, Nf3, Bxe4
- **Captures**: exd4, Nxd4, Bxf7
- **Castling**: O-O, O-O-O with check/mate (O-O+, O-O#)
- **Promotions**: g8=Q, a1=R# with check/mate (e8=Q+, e8=Q#)
- **En passant**: exd6, exd6e.p., exd6ep with validation
- **Complex disambiguation**: Rae1, R1e1, Ra1e1, Nbd7, N1d7
- **Edge case handling** for all move types

### 🌐 API Integration
- **Lichess API**: fetching and parsing real games from Lichess
  - Detailed player statistics with ratings
  - Real-time ongoing games
  - Comprehensive JSON API response parsing
- **Chess.com API**: fetching games, player stats, tournaments, and daily puzzles
  - Player games by username with filtering
  - Top player ongoing games and leaderboards
  - Game search with multiple filters
  - Individual game fetching by ID

### 🔧 Advanced Features
- **Board tracking**: maintaining board state throughout the game
- **Zobrist hashing**: fast position comparison
- **Position comparison**: efficient chess position comparison
- **Unfinished games support**: handling ongoing and incomplete games

### 🧪 Testing
- **Property-based testing** with QCheck2
- **Round-trip parsing**: parse → reconstruct → validate parsing
- **Comprehensive testing** of all components

## Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/Ckaf/pgn_parser.git
cd pgn_parser

# Install dependencies
opam install qcheck

# Build the project
dune build
```

### Basic Usage

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

## Usage Examples

### Running Demo Programs

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

### Running Tests

```bash
# All tests
dune runtest

# Specific test suites
dune exec test/test_pgn_parser        # Property-based tests
dune exec test/test_zobrist           # Zobrist hash tests
dune exec test/test_advanced_moves    # Advanced moves
dune exec test/test_unfinished_games  # Unfinished games
```

## Architecture

### Core Modules

- **`Pgn_parser`**: main PGN parsing module
- **`Lichess_api`**: Lichess API client
- **`Chess_com_api`**: Chess.com API client

### Data Types

```ocaml
type piece = King | Queen | Rook | Bishop | Knight | Pawn
type square = char * int
type board = (piece option * bool) array array
type zobrist_hash = int64

type move_type =
  | Normal of piece * square * square
  | Capture of piece * square * square * piece option
  | Castle of bool
  | EnPassant of square * square
  | Promotion of square * square * piece
  | Check | Checkmate | Draw
```

## API Documentation

### Core Functions

- `parse_game : string -> game parse_result` - parse a single PGN game
- `parse_document : string -> pgn_document parse_result` - parse multiple games
- `to_pgn : game -> string` - convert game back to PGN
- `create_starting_position : unit -> board` - create starting position
- `calculate_zobrist_hash : board -> zobrist_hash` - calculate Zobrist hash

### Visualization

- `print_board : board -> unit` - print board to stdout
- `board_to_string : board -> string` - get board as string
- `visualize_game_progression : game -> string` - visualize game progression

## API Integration

### Lichess API

```ocaml
open Lwt.Syntax
open Lichess_api

let* game_opt = fetch_random_game () in
match game_opt with
| Some game ->
    Printf.printf "Game: %s vs %s\n" game.white game.black;
    Printf.printf "PGN length: %d characters\n" (String.length game.pgn)
| None -> Printf.printf "No game found\n"
```

### Chess.com API

```ocaml
open Lwt.Syntax
open Chess_com_api

let* games = fetch_player_games "hikaru" ~max_games:5 () in
List.iter (fun game ->
  Printf.printf "Game: %s vs %s (%s)\n" game.white game.black game.speed
) games
```

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

## CI/CD

The project uses GitHub Actions for continuous integration:

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

## Limitations

The current implementation has some limitations:
- Limited support for complex move annotations
- No support for comments or NAG codes
- Basic move parsing (doesn't validate chess rules)
- No support for FEN position parsing
- No support for move annotations like "!", "?", "!!", "??", etc.

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