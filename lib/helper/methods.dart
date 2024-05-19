import 'package:chess/components/piece.dart';
import 'package:flutter/material.dart';

bool isWhite(int index) {
  int row = index ~/ 8;
  int col = index % 8;
  return (row % 2 == 0 && col % 2 != 0) || (row % 2 != 0 && col % 2 == 0);
}

bool isInBoard(int row, int col) {
  return row >= 0 && row < 8 && col >= 0 && col < 8;
}

double calculateSquareSize(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  final minDimension = screenWidth < screenHeight ? screenWidth : screenHeight;
  return minDimension / 8;
}

String getImagePath(ChessPiece piece) {
  String color = piece.isWhite ? 'white' : 'black';
  String pieceType = piece.type.toString().split('.')[1];
  return 'assets/$color' + '_$pieceType.png';
}

String getPieceSymbol(ChessPiece piece) {
  switch (piece.type) {
    case ChessPieceTypes.pawn:
      return "♙";
    case ChessPieceTypes.rook:
      return "♖";
    case ChessPieceTypes.knight:
      return "♘";
    case ChessPieceTypes.bishop:
      return "♗";
    case ChessPieceTypes.queen:
      return "♕";
    case ChessPieceTypes.king:
      return "♔";
  }
}

List<List<int>> filterValidMoves(
    List<List<int>> moves, ChessPiece piece, List<List<ChessPiece?>> board) {
  return moves
      .where((move) =>
          isInBoard(move[0], move[1]) &&
          (board[move[0]][move[1]] == null ||
              board[move[0]][move[1]]!.isWhite != piece.isWhite))
      .toList();
}

List<List<int>> generateLineMoves(int row, int col, int rowIncrement,
    int colIncrement, List<List<ChessPiece?>> board) {
  List<List<int>> moves = [];
  int newRow = row + rowIncrement;
  int newCol = col + colIncrement;
  while (isInBoard(newRow, newCol) &&
      (board[newRow][newCol] == null ||
          board[newRow][newCol]!.isWhite != board[row][col]!.isWhite)) {
    moves.add([newRow, newCol]);
    if (board[newRow][newCol] != null) break;
    newRow += rowIncrement;
    newCol += colIncrement;
  }
  return moves;
}

List<List<int>> calculateRawValidMoves(
    int row, int col, ChessPiece? piece, List<List<ChessPiece?>> board) {
  List<List<int>> candidateMoves = [];
  if (piece == null) return candidateMoves;

  int direction = piece.isWhite ? -1 : 1;
  switch (piece.type) {
    case ChessPieceTypes.pawn:
      if (isInBoard(row + direction, col) &&
          board[row + direction][col] == null) {
        candidateMoves.add([row + direction, col]);
      }
      if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
        if (isInBoard(row + 2 * direction, col) &&
            board[row + 2 * direction][col] == null &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + 2 * direction, col]);
        }
      }
      if (isInBoard(row + direction, col - 1) &&
          board[row + direction][col - 1] != null &&
          board[row + direction][col - 1]!.isWhite != piece.isWhite) {
        candidateMoves.add([row + direction, col - 1]);
      }
      if (isInBoard(row + direction, col + 1) &&
          board[row + direction][col + 1] != null &&
          board[row + direction][col + 1]!.isWhite != piece.isWhite) {
        candidateMoves.add([row + direction, col + 1]);
      }
      break;
    case ChessPieceTypes.rook:
      candidateMoves.addAll(generateLineMoves(row, col, 1, 0, board));
      candidateMoves.addAll(generateLineMoves(row, col, -1, 0, board));
      candidateMoves.addAll(generateLineMoves(row, col, 0, 1, board));
      candidateMoves.addAll(generateLineMoves(row, col, 0, -1, board));
      break;
    case ChessPieceTypes.knight:
      List<List<int>> knightMoves = [
        [row + 2, col + 1],
        [row + 2, col - 1],
        [row - 2, col + 1],
        [row - 2, col - 1],
        [row + 1, col + 2],
        [row + 1, col - 2],
        [row - 1, col + 2],
        [row - 1, col - 2]
      ];
      candidateMoves.addAll(filterValidMoves(knightMoves, piece, board));
      break;
    case ChessPieceTypes.bishop:
      candidateMoves.addAll(generateLineMoves(row, col, 1, 1, board));
      candidateMoves.addAll(generateLineMoves(row, col, 1, -1, board));
      candidateMoves.addAll(generateLineMoves(row, col, -1, 1, board));
      candidateMoves.addAll(generateLineMoves(row, col, -1, -1, board));
      break;
    case ChessPieceTypes.queen:
      candidateMoves.addAll(generateLineMoves(row, col, 1, 0, board));
      candidateMoves.addAll(generateLineMoves(row, col, -1, 0, board));
      candidateMoves.addAll(generateLineMoves(row, col, 0, 1, board));
      candidateMoves.addAll(generateLineMoves(row, col, 0, -1, board));
      candidateMoves.addAll(generateLineMoves(row, col, 1, 1, board));
      candidateMoves.addAll(generateLineMoves(row, col, 1, -1, board));
      candidateMoves.addAll(generateLineMoves(row, col, -1, 1, board));
      candidateMoves.addAll(generateLineMoves(row, col, -1, -1, board));
      break;
    case ChessPieceTypes.king:
      List<List<int>> kingMoves = [
        [row + 1, col],
        [row - 1, col],
        [row, col + 1],
        [row, col - 1],
        [row + 1, col + 1],
        [row + 1, col - 1],
        [row - 1, col + 1],
        [row - 1, col - 1]
      ];
      candidateMoves.addAll(filterValidMoves(kingMoves, piece, board));
      break;
    default:
  }
  return candidateMoves;
}
