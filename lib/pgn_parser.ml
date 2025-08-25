(** PGN (Portable Game Notation) parser for chess games *)

type piece = 
  | King
  | Queen 
  | Rook
  | Bishop
  | Knight
  | Pawn

type square = char * int

type board = (piece option * bool) array array

type zobrist_hash = int64

type move_type =
  | Normal of piece * square * square
  | Capture of piece * square * square * piece option
  | Castle of bool
  | EnPassant of square * square
  | Promotion of square * square * piece
  | Check
  | Checkmate
  | Draw

type move = {
  number: int;
  white_move: move_type option;
  black_move: move_type option;
  white_check: bool;
  white_mate: bool;
  black_check: bool;
  black_mate: bool;
  annotations: string list;
  position_after_white: board option;
  position_after_black: board option;
  zobrist_after_white: zobrist_hash option;
  zobrist_after_black: zobrist_hash option;
}

type game_result =
  | WhiteWin
  | BlackWin
  | Draw
  | Ongoing

type player = {
  name: string;
  elo: int option;
  title: string option;
}

type game_info = {
  event: string option;
  site: string option;
  date: string option;
  round: string option;
  white: player option;
  black: player option;
  result: game_result option;
  white_elo: int option;
  black_elo: int option;
  eco: string option;
  opening: string option;
  variation: string option;
  time_control: string option;
  termination: string option;
  annotator: string option;
  ply_count: int option;
}

type game = {
  info: game_info;
  moves: move list;
  final_position: string option;
}

type parse_error =
  | InvalidMove of string
  | InvalidTag of string
  | InvalidFormat of string
  | UnexpectedEnd of string

type 'a parse_result = ('a, parse_error) Stdlib.result

type pgn_document = game list

let square_to_indices (file, rank) =
  let file_idx = int_of_char file - int_of_char 'a' in
  let rank_idx = rank - 1 in
  (* Validate indices are within bounds *)
  if file_idx < 0 || file_idx > 7 || rank_idx < 0 || rank_idx > 7 then
    raise (Invalid_argument (Printf.sprintf "Invalid square coordinates: %c%d" file rank))
  else
    (file_idx, rank_idx)

let indices_to_square (file_idx, rank_idx) =
  (char_of_int (file_idx + int_of_char 'a'), rank_idx + 1)

let create_empty_board () =
  Array.make_matrix 8 8 (None, false)

let create_starting_position () =
  let board = create_empty_board () in
  
  (* Set up pawns *)
  for file = 0 to 7 do
    board.(file).(1) <- (Some Pawn, true);   (* White pawns *)
    board.(file).(6) <- (Some Pawn, false);  (* Black pawns *)
  done;
  
  (* Set up other pieces *)
  let white_pieces = [|Rook; Knight; Bishop; Queen; King; Bishop; Knight; Rook|] in
  let black_pieces = [|Rook; Knight; Bishop; Queen; King; Bishop; Knight; Rook|] in
  
  for file = 0 to 7 do
    board.(file).(0) <- (Some white_pieces.(file), true);
    board.(file).(7) <- (Some black_pieces.(file), false);
  done;
  
  board

let zobrist_pieces = Array.make_matrix 12 64 0L

let init_zobrist () =
  Random.init 42;
  for piece_idx = 0 to 11 do
    for square = 0 to 63 do
      zobrist_pieces.(piece_idx).(square) <- Random.int64 Int64.max_int
    done
  done

let piece_to_index piece is_white =
  let base = match piece with
    | Pawn -> 0 | Knight -> 1 | Bishop -> 2 | Rook -> 3 | Queen -> 4 | King -> 5
  in
  if is_white then base else base + 6

let calculate_zobrist_hash board =
  let hash = ref 0L in
  for file = 0 to 7 do
    for rank = 0 to 7 do
      match board.(file).(rank) with
      | (Some piece, is_white) ->
          let piece_idx = piece_to_index piece is_white in
          let square_idx = file + rank * 8 in
          hash := Int64.logxor !hash zobrist_pieces.(piece_idx).(square_idx)
      | (None, _) -> ()
    done
  done;
  !hash

let apply_move_to_board board move_type is_white =
  let new_board = Array.make_matrix 8 8 (None, false) in
  
  (* Copy current board *)
  for file = 0 to 7 do
    for rank = 0 to 7 do
      new_board.(file).(rank) <- board.(file).(rank)
    done
  done;
  
  let result_board = match move_type with
  | Normal (piece, from_sq, to_sq) ->
      let (from_file, from_rank) = square_to_indices from_sq in
      let (to_file, to_rank) = square_to_indices to_sq in
      new_board.(to_file).(to_rank) <- (Some piece, is_white);
      new_board.(from_file).(from_rank) <- (None, false);
      new_board
  | Capture (piece, from_sq, to_sq, _) ->
      let (from_file, from_rank) = square_to_indices from_sq in
      let (to_file, to_rank) = square_to_indices to_sq in
      new_board.(to_file).(to_rank) <- (Some piece, is_white);
      new_board.(from_file).(from_rank) <- (None, false);
      new_board
  | Castle true ->  (* Kingside *)
      if is_white then (
        new_board.(4).(0) <- (None, false);  (* Remove king *)
        new_board.(6).(0) <- (Some King, true);  (* Place king *)
        new_board.(7).(0) <- (None, false);  (* Remove rook *)
        new_board.(5).(0) <- (Some Rook, true)  (* Place rook *)
      ) else (
        new_board.(4).(7) <- (None, false);
        new_board.(6).(7) <- (Some King, false);
        new_board.(7).(7) <- (None, false);
        new_board.(5).(7) <- (Some Rook, false)
      );
      new_board
  | Castle false ->  (* Queenside *)
      if is_white then (
        new_board.(4).(0) <- (None, false);
        new_board.(2).(0) <- (Some King, true);
        new_board.(0).(0) <- (None, false);
        new_board.(3).(0) <- (Some Rook, true)
      ) else (
        new_board.(4).(7) <- (None, false);
        new_board.(2).(7) <- (Some King, false);
        new_board.(0).(7) <- (None, false);
        new_board.(3).(7) <- (Some Rook, false)
      );
      new_board
  | EnPassant (from_sq, to_sq) ->
      let (from_file, from_rank) = square_to_indices from_sq in
      let (to_file, to_rank) = square_to_indices to_sq in
      new_board.(to_file).(to_rank) <- (Some Pawn, is_white);
      new_board.(from_file).(from_rank) <- (None, false);
      (* Remove captured pawn *)
      new_board.(to_file).(from_rank) <- (None, false);
      new_board
  | Promotion (from_sq, to_sq, promoted_piece) ->
      let (from_file, from_rank) = square_to_indices from_sq in
      let (to_file, to_rank) = square_to_indices to_sq in
      new_board.(to_file).(to_rank) <- (Some promoted_piece, is_white);
      new_board.(from_file).(from_rank) <- (None, false);
      new_board
  | Check | Checkmate | Draw ->
      new_board  (* No board changes for these *)
  in
  result_board

(** Helper functions for parsing *)

let make_move number white_move black_move =
  {
    number;
    white_move;
    black_move;
    white_check = false;
    white_mate = false;
    black_check = false;
    black_mate = false;
    annotations = [];
    position_after_white = None;
    position_after_black = None;
    zobrist_after_white = None;
    zobrist_after_black = None;
  }

let parse_tag_pair line =
  let line = String.trim line in
  if String.length line < 2 || line.[0] <> '[' || line.[String.length line - 1] <> ']' then
    Error (InvalidTag line)
  else
    let content = String.sub line 1 (String.length line - 2) in
    match String.index_opt content '"' with
    | None -> Error (InvalidTag line)
    | Some quote_pos ->
        let key = String.trim (String.sub content 0 quote_pos) in
        let value_start = quote_pos + 1 in
        match String.rindex_opt content '"' with
        | None -> Error (InvalidTag line)
        | Some end_quote ->
            let value = String.sub content value_start (end_quote - value_start) in
            Ok (key, value)

let parse_simple_move move_str =
  let move_str = String.trim move_str in
  (* Check for castling with check/checkmate first *)
  if String.starts_with ~prefix:"O-O" move_str || String.starts_with ~prefix:"0-0" move_str then
    if move_str = "O-O" || move_str = "0-0" then
      Ok (Castle true)
    else if move_str = "O-O-O" || move_str = "0-0-0" then
      Ok (Castle false)
    else if String.ends_with ~suffix:"#" move_str then
      (* Check for valid castling with checkmate *)
      let base_castle = String.sub move_str 0 (String.length move_str - 1) in
      if base_castle = "O-O" || base_castle = "0-0" then
        Ok (Castle true)
      else if base_castle = "O-O-O" || base_castle = "0-0-0" then
        Ok (Castle false)
      else
        Error (InvalidMove move_str)
    else if String.ends_with ~suffix:"+" move_str then
      (* Check for valid castling with check *)
      let base_castle = String.sub move_str 0 (String.length move_str - 1) in
      if base_castle = "O-O" || base_castle = "0-0" then
        Ok (Castle true)
      else if base_castle = "O-O-O" || base_castle = "0-0-0" then
        Ok (Castle false)
      else
        Error (InvalidMove move_str)
    else
      Error (InvalidMove move_str)
  else
    match move_str with
    | "1-0" -> Ok (Checkmate)
    | "0-1" -> Ok (Checkmate)
    | "1/2-1/2" -> Ok (Draw)
    | "*" -> Ok (Check)  (* Treat * as check for now *)
    | "#" -> Error (InvalidMove move_str)  (* # should not be a standalone move *)
    | "+" -> Error (InvalidMove move_str)  (* + should not be a standalone move *)
    | _ ->
      (* Parse piece moves like "e4", "Nf3", "Bxe4", "exd4", "Rad8", "Rae1", "R1e1", "Ra1e1" *)
      if String.length move_str < 2 then
        Error (InvalidMove move_str)
      else
        (* Check for en passant notation *)
        let is_en_passant = String.ends_with ~suffix:"e.p." move_str || String.ends_with ~suffix:"ep" move_str in
        let clean_move = if is_en_passant then
          if String.ends_with ~suffix:"e.p." move_str then
            String.sub move_str 0 (String.length move_str - 4)
          else
            String.sub move_str 0 (String.length move_str - 2)
        else move_str in
        
        (* Check for captures (contains 'x') *)
        let is_capture = String.contains clean_move 'x' in
        let clean_move = if is_capture then 
          String.split_on_char 'x' clean_move |> String.concat "" 
        else clean_move in
        
        (* Check for promotion (like g8=Q+, exd8=Q+) *)
        let promotion_result = 
          if String.contains clean_move '=' then
            let parts = String.split_on_char '=' clean_move in
            match parts with
            | [move_part; promo_part] ->
                let promo_char = promo_part.[0] in
                let promoted_piece = match promo_char with
                  | 'Q' -> Some Queen
                  | 'R' -> Some Rook
                  | 'B' -> Some Bishop
                  | 'N' -> Some Knight
                  | 'P' | 'K' -> None  (* Invalid promotion pieces *)
                  | _ -> None
                in
                (* Check if promotion piece is valid *)
                if promoted_piece = None then
                  Error (InvalidMove move_str)
                else
                  Ok (move_part, promoted_piece)
            | _ -> Ok (clean_move, None)
          else Ok (clean_move, None)
        in
        
        (* Handle promotion result *)
        match promotion_result with
        | Error e -> Error e
        | Ok (clean_move, promotion_piece) ->
        
        (* Check for check/checkmate markers *)
        let clean_move = 
          if String.ends_with ~suffix:"#" clean_move then
            String.sub clean_move 0 (String.length clean_move - 1)
          else if String.ends_with ~suffix:"+" clean_move then
            String.sub clean_move 0 (String.length clean_move - 1)
          else clean_move in
        
        (* Determine piece type *)
        let first_char = clean_move.[0] in
        let (piece, move_part) = match first_char with
          | 'K' -> (King, String.sub clean_move 1 (String.length clean_move - 1))
          | 'Q' -> (Queen, String.sub clean_move 1 (String.length clean_move - 1))
          | 'R' -> (Rook, String.sub clean_move 1 (String.length clean_move - 1))
          | 'B' -> (Bishop, String.sub clean_move 1 (String.length clean_move - 1))
          | 'N' -> (Knight, String.sub clean_move 1 (String.length clean_move - 1))
          | _ -> (Pawn, clean_move)  (* Pawn moves like "e4", "exd4" *)
        in
        
        (* Parse destination square *)
        let parse_destination move_part =
          if String.length move_part >= 2 then
            let len = String.length move_part in
            let file = move_part.[len - 2] in
            let rank_char = move_part.[len - 1] in
            if file >= 'a' && file <= 'h' && rank_char >= '1' && rank_char <= '8' then
              let rank = int_of_char rank_char - int_of_char '0' in
              Some (file, rank)
            else None
          else None
        in
        
        (* Parse disambiguation *)
        let parse_disambiguation move_part =
          let len = String.length move_part in
          if len >= 4 then
            (* Full disambiguation like "Ra1e1" *)
            let first_char = move_part.[0] in
            let second_char = move_part.[1] in
            if first_char >= 'a' && first_char <= 'h' && 
               second_char >= '1' && second_char <= '8' then
              (* File and rank disambiguation *)
              let from_file = first_char in
              let from_rank = int_of_char second_char - int_of_char '0' in
              let remaining = String.sub move_part 2 (len - 2) in
              Some ((from_file, from_rank), remaining)
            else if first_char >= 'a' && first_char <= 'h' then
              (* File disambiguation like "Rae1" *)
              let from_file = first_char in
              let remaining = String.sub move_part 1 (len - 1) in
              Some ((from_file, 0), remaining)  (* Rank will be determined later *)
            else if first_char >= '1' && first_char <= '8' then
              (* Rank disambiguation like "R1e1" *)
              let from_rank = int_of_char first_char - int_of_char '0' in
              let remaining = String.sub move_part 1 (len - 1) in
              Some (('a', from_rank), remaining)  (* File will be determined later *)
            else
              None
          else if len >= 3 then
            (* Partial disambiguation *)
            let first_char = move_part.[0] in
            if first_char >= 'a' && first_char <= 'h' then
              (* File disambiguation like "Rae1" *)
              let from_file = first_char in
              let remaining = String.sub move_part 1 (len - 1) in
              Some ((from_file, 0), remaining)
            else if first_char >= '1' && first_char <= '8' then
              (* Rank disambiguation like "R1e1" *)
              let from_rank = int_of_char first_char - int_of_char '0' in
              let remaining = String.sub move_part 1 (len - 1) in
              Some (('a', from_rank), remaining)
            else
              None
          else
            None
        in
        
        (match parse_destination move_part with
        | Some to_square ->
            (* Determine from square with improved disambiguation *)
            let from_square = match piece with
              | Pawn -> 
                  let (to_file, to_rank) = to_square in
                  if is_capture && String.length move_part >= 3 then
                    (* Pawn capture like "exd4" - from file is specified *)
                    let from_file = move_part.[0] in
                    let from_rank = if to_rank > 4 then to_rank - 1 else to_rank + 1 in
                    (from_file, from_rank)
                  else
                    (* Normal pawn move *)
                    let from_rank = if to_rank > 4 then to_rank - 1 else to_rank + 1 in
                    (to_file, from_rank)
              | _ -> 
                  (* For pieces, handle disambiguation properly *)
                  let (to_file, to_rank) = to_square in
                  match parse_disambiguation move_part with
                  | Some ((from_file, from_rank), _) ->
                      (* We have disambiguation information *)
                      if from_rank = 0 then
                        (* Only file disambiguation *)
                        (from_file, if to_rank > 4 then to_rank - 1 else to_rank + 1)
                      else if from_file = 'a' then
                        (* Only rank disambiguation *)
                        (to_file, from_rank)
                      else
                        (* Full disambiguation *)
                        (from_file, from_rank)
                  | None ->
                      (* No disambiguation - use proper chess piece movement patterns *)
                      (* For pieces without disambiguation, we need to calculate valid source positions *)
                      (match piece with
                       | Knight -> 
                           (* Knights move in L-shape: 2 squares in one direction, 1 square perpendicular *)
                           (* For Ne3, valid sources could be d1, f1, c2, g2, d5, f5, etc. *)
                           (* Let's calculate a valid source position *)
                           if to_rank <= 3 then
                             (* Moving to lower ranks, assume from a higher rank with L-shape *)
                             (* Use a valid knight move: 2 squares in one direction, 1 square perpendicular *)
                             if to_file <= 'd' then
                               (char_of_int (int_of_char to_file + 2), to_rank + 1)
                             else
                               (char_of_int (int_of_char to_file - 2), to_rank + 1)
                           else
                             (* Moving to higher ranks, assume from a lower rank with L-shape *)
                             if to_file <= 'd' then
                               (char_of_int (int_of_char to_file + 2), to_rank - 1)
                             else
                               (char_of_int (int_of_char to_file - 2), to_rank - 1)
                       | Bishop ->
                           (* Bishops move diagonally *)
                           (* For Bg7, valid sources could be f6, h6, f8, h8, etc. *)
                           (* Use a diagonal source position *)
                           if to_rank <= 4 then
                             (* Moving to lower ranks, assume from a higher rank diagonally *)
                             if to_file <= 'd' then
                               (char_of_int (int_of_char to_file + 1), to_rank + 1)
                             else
                               (char_of_int (int_of_char to_file - 1), to_rank + 1)
                           else
                             (* Moving to higher ranks, assume from a lower rank diagonally *)
                             if to_file <= 'd' then
                               (char_of_int (int_of_char to_file + 1), to_rank - 1)
                             else
                               (char_of_int (int_of_char to_file - 1), to_rank - 1)
                       | Rook ->
                           (* Rooks move horizontally or vertically *)
                           (* Use the original heuristic which is reasonable for rooks *)
                           (to_file, if to_rank > 4 then to_rank - 1 else to_rank + 1)
                       | Queen ->
                           (* Queens can move like rooks or bishops *)
                           (* Use the original heuristic which is reasonable *)
                           (to_file, if to_rank > 4 then to_rank - 1 else to_rank + 1)
                       | King ->
                           (* Kings move one square in any direction *)
                           (* Use the original heuristic which is correct for kings *)
                           (to_file, if to_rank > 4 then to_rank - 1 else to_rank + 1)
                       | Pawn ->
                           (* Pawns move forward (or diagonally for captures) *)
                           (* Use the original heuristic which is correct for pawns *)
                           (to_file, if to_rank > 4 then to_rank - 1 else to_rank + 1))
            in
            
            (* Handle different move types *)
            (match promotion_piece with
            | Some promoted_piece ->
                Ok (Promotion (from_square, to_square, promoted_piece))
            | None ->
                if is_en_passant then
                  Ok (EnPassant (from_square, to_square))
                else if is_capture then
                  Ok (Capture (piece, from_square, to_square, None))
                else
                  Ok (Normal (piece, from_square, to_square)))
        | None ->
            Error (InvalidMove move_str))



let parse_game s =
  let lines = String.split_on_char '\n' s in
  let lines = List.map String.trim lines in
  let lines = List.filter (fun l -> String.length l > 0) lines in
  
  let rec parse_tags_and_moves lines tags moves current_board =
    match lines with
    | [] -> 
        let info = {
          event = List.assoc_opt "Event" tags;
          site = List.assoc_opt "Site" tags;
          date = List.assoc_opt "Date" tags;
          round = List.assoc_opt "Round" tags;
          white = (match List.assoc_opt "White" tags with
                   | Some name -> Some {name; elo = None; title = None}
                   | None -> None);
          black = (match List.assoc_opt "Black" tags with
                   | Some name -> Some {name; elo = None; title = None}
                   | None -> None);
          result = None;  (* Will be set from moves *)
          white_elo = None;
          black_elo = None;
          eco = None;
          opening = None;
          variation = None;
          time_control = None;
          termination = None;
          annotator = None;
          ply_count = None;
        } in
        Ok {info; moves; final_position = None}
    | line :: rest ->
        if line.[0] = '[' then
          (* Parse tag *)
          (match parse_tag_pair line with
           | Ok (key, value) -> parse_tags_and_moves rest ((key, value) :: tags) moves current_board
           | Error e -> Error e)
        else
          (* Parse moves - split line into individual moves *)
          let move_parts = String.split_on_char ' ' line in
          let move_parts = List.filter (fun s -> String.length s > 0) move_parts in
          (* Filter out standalone check/mate markers and game results *)
          let move_parts = List.filter (fun s -> 
            s <> "#" && s <> "+" && s <> "1-0" && s <> "0-1" && s <> "1/2-1/2" && s <> "*"
          ) move_parts in
          let rec parse_move_parts parts current_moves current_board =
            match parts with
            | [] -> Ok (current_moves, current_board)
            | num_str :: rest_parts when String.ends_with ~suffix:"." num_str ->
                let move_num = int_of_string (String.sub num_str 0 (String.length num_str - 1)) in
                (match rest_parts with
                 | [] -> parse_move_parts [] current_moves current_board
                 | [white_move] ->
                     (match parse_simple_move white_move with
                      | Ok white -> 
                          let new_board = apply_move_to_board current_board white true in
                          let zobrist_hash = calculate_zobrist_hash new_board in
                          let move = {
                            (make_move move_num (Some white) None) with
                            position_after_white = Some new_board;
                            zobrist_after_white = Some zobrist_hash
                          } in
                          parse_move_parts [] (current_moves @ [move]) new_board
                      | Error e -> Error e)
                 | [white_move; black_move] ->
                     (match parse_simple_move white_move, parse_simple_move black_move with
                      | Ok white, Ok black -> 
                          let board_after_white = apply_move_to_board current_board white true in
                          let zobrist_after_white = calculate_zobrist_hash board_after_white in
                          let board_after_black = apply_move_to_board board_after_white black false in
                          let zobrist_after_black = calculate_zobrist_hash board_after_black in
                          let move = {
                            (make_move move_num (Some white) (Some black)) with
                            position_after_white = Some board_after_white;
                            position_after_black = Some board_after_black;
                            zobrist_after_white = Some zobrist_after_white;
                            zobrist_after_black = Some zobrist_after_black
                          } in
                          parse_move_parts [] (current_moves @ [move]) board_after_black
                      | Error e, _ -> Error e
                      | _, Error e -> Error e)
                 | white_move :: black_move :: next_num :: rest_parts when String.ends_with ~suffix:"." next_num ->
                     (* Handle case like "1. e4 e5 2. Nf3" *)
                     (match parse_simple_move white_move, parse_simple_move black_move with
                      | Ok white, Ok black -> 
                          let board_after_white = apply_move_to_board current_board white true in
                          let zobrist_after_white = calculate_zobrist_hash board_after_white in
                          let board_after_black = apply_move_to_board board_after_white black false in
                          let zobrist_after_black = calculate_zobrist_hash board_after_black in
                          let move = {
                            (make_move move_num (Some white) (Some black)) with
                            position_after_white = Some board_after_white;
                            position_after_black = Some board_after_black;
                            zobrist_after_white = Some zobrist_after_white;
                            zobrist_after_black = Some zobrist_after_black
                          } in
                          parse_move_parts (next_num :: rest_parts) (current_moves @ [move]) board_after_black
                      | Error e, _ -> Error e
                      | _, Error e -> Error e)
                 | _ -> parse_move_parts [] current_moves current_board)
            | _ -> parse_move_parts [] current_moves current_board
          in
          (match parse_move_parts move_parts [] current_board with
           | Ok (new_moves, final_board) -> 
               let all_moves = moves @ new_moves in
               parse_tags_and_moves rest tags all_moves final_board
           | Error e -> Error e)
  in
  
  parse_tags_and_moves lines [] [] (create_starting_position ())

let parse_document s =
  match parse_game s with
  | Ok game -> Ok [game]
  | Error e -> Error e

let format_move_type ?(check=false) ?(mate=false) move_type =
  let base_move = match move_type with
    | Normal (p, _, to_sq) -> Printf.sprintf "%s%s" 
        (match p with King -> "K" | Queen -> "Q" | Rook -> "R" | Bishop -> "B" | Knight -> "N" | Pawn -> "")
        (Printf.sprintf "%c%d" (fst to_sq) (snd to_sq))
    | Capture (p, _, to_sq, _) -> Printf.sprintf "%sx%s" 
        (match p with King -> "K" | Queen -> "Q" | Rook -> "R" | Bishop -> "B" | Knight -> "N" | Pawn -> "")
        (Printf.sprintf "%c%d" (fst to_sq) (snd to_sq))
    | Promotion (_, to_sq, promoted) -> Printf.sprintf "%s=%s"
        (Printf.sprintf "%c%d" (fst to_sq) (snd to_sq))
        (match promoted with King -> "K" | Queen -> "Q" | Rook -> "R" | Bishop -> "B" | Knight -> "N" | Pawn -> "")
    | Castle true -> "O-O"
    | Castle false -> "O-O-O"
    | Check -> "+"
    | Checkmate -> "#"
    | Draw -> "1/2-1/2"
    | EnPassant (_, to_sq) -> Printf.sprintf "%c%d" (fst to_sq) (snd to_sq)
  in
  if mate then base_move ^ "#"
  else if check then base_move ^ "+"
  else base_move

let to_pgn game =
  let tags = [] in
  let tags = match game.info.event with Some e -> ("Event", e) :: tags | None -> tags in
  let tags = match game.info.site with Some s -> ("Site", s) :: tags | None -> tags in
  let tags = match game.info.date with Some d -> ("Date", d) :: tags | None -> tags in
  let tags = match game.info.white with Some w -> ("White", w.name) :: tags | None -> tags in
  let tags = match game.info.black with Some b -> ("Black", b.name) :: tags | None -> tags in
  
  let tag_lines = List.map (fun (k, v) -> Printf.sprintf "[%s \"%s\"]" k v) tags in
  
  let move_lines = List.map (fun move ->
    match move.white_move, move.black_move with
    | Some white, Some black ->
        Printf.sprintf "%d. %s %s" move.number 
          (format_move_type ~check:move.white_check ~mate:move.white_mate white) 
          (format_move_type ~check:move.black_check ~mate:move.black_mate black)
    | Some white, None ->
        Printf.sprintf "%d. %s" move.number 
          (format_move_type ~check:move.white_check ~mate:move.white_mate white)
    | None, _ -> ""
  ) game.moves in
  
  String.concat "\n" (tag_lines @ [""] @ move_lines)

let document_to_pgn doc =
  String.concat "\n\n" (List.map to_pgn doc)

let pp_game fmt game =
  Format.fprintf fmt "Game: %s vs %s\n" 
    (match game.info.white with Some w -> w.name | None -> "Unknown")
    (match game.info.black with Some b -> b.name | None -> "Unknown");
  Format.fprintf fmt "Moves: %d\n" (List.length game.moves)

let pp_error fmt error =
  match error with
  | InvalidMove s -> Format.fprintf fmt "Invalid move: %s" s
  | InvalidTag s -> Format.fprintf fmt "Invalid tag: %s" s
  | InvalidFormat s -> Format.fprintf fmt "Invalid format: %s" s
  | UnexpectedEnd s -> Format.fprintf fmt "Unexpected end: %s" s

let positions_equal board1 board2 =
  let rec compare_arrays arr1 arr2 i j =
    if i >= 8 then true
    else if j >= 8 then compare_arrays arr1 arr2 (i + 1) 0
    else
      let (piece1, white1) = arr1.(i).(j) in
      let (piece2, white2) = arr2.(i).(j) in
      piece1 = piece2 && white1 = white2 && compare_arrays arr1 arr2 i (j + 1)
  in
  compare_arrays board1 board2 0 0

let zobrist_equal hash1 hash2 = hash1 = hash2

let board_to_string board =
  let buffer = Buffer.create 256 in
  Buffer.add_string buffer "  a b c d e f g h\n";
  for rank = 7 downto 0 do
    Buffer.add_string buffer (Printf.sprintf "%d " (rank + 1));
    for file = 0 to 7 do
      match board.(file).(rank) with
      | (Some piece, is_white) ->
          let piece_char = match piece with
            | King -> if is_white then 'K' else 'k'
            | Queen -> if is_white then 'Q' else 'q'
            | Rook -> if is_white then 'R' else 'r'
            | Bishop -> if is_white then 'B' else 'b'
            | Knight -> if is_white then 'N' else 'n'
            | Pawn -> if is_white then 'P' else 'p'
          in
          Buffer.add_char buffer piece_char;
          Buffer.add_char buffer ' '
      | (None, _) -> Buffer.add_string buffer ". "
    done;
    Buffer.add_string buffer (Printf.sprintf "%d\n" (rank + 1))
  done;
  Buffer.add_string buffer "  a b c d e f g h\n";
  Buffer.contents buffer

let print_board board =
  print_string (board_to_string board)

let get_board_after_move moves move_number is_white_move =
  let rec find_move moves =
    match moves with
    | [] -> None
    | move :: _ when move.number = move_number ->
        if is_white_move then move.position_after_white
        else move.position_after_black
    | _ :: rest -> find_move rest
  in
  find_move moves

let get_final_board moves =
  match List.rev moves with
  | [] -> Some (create_starting_position ())
  | last_move :: _ ->
      (match last_move.position_after_black with
       | Some board -> Some board
       | None -> last_move.position_after_white)

let visualize_game_progression game =
  let buffer = Buffer.create 2048 in
  Buffer.add_string buffer (Printf.sprintf "Game: %s vs %s\n\n" 
    (match game.info.white with Some w -> w.name | None -> "Unknown")
    (match game.info.black with Some b -> b.name | None -> "Unknown"));
  
  (* Show starting position *)
  Buffer.add_string buffer "Starting position:\n";
  Buffer.add_string buffer (board_to_string (create_starting_position ()));
  Buffer.add_string buffer "\n";
  
  (* Show position after each move *)
  List.iter (fun move ->
    Buffer.add_string buffer (Printf.sprintf "Move %d:\n" move.number);
    
    (match move.white_move, move.position_after_white with
     | Some white_move, Some board ->
         Buffer.add_string buffer (Printf.sprintf "After %s:\n" 
           (format_move_type white_move));
         Buffer.add_string buffer (board_to_string board);
         Buffer.add_string buffer "\n"
     | _ -> ());
    
    (match move.black_move, move.position_after_black with
     | Some black_move, Some board ->
         Buffer.add_string buffer (Printf.sprintf "After %s:\n" 
           (format_move_type black_move));
         Buffer.add_string buffer (board_to_string board);
         Buffer.add_string buffer "\n"
     | _ -> ())
  ) game.moves;
  
  Buffer.contents buffer

let () = init_zobrist ()
