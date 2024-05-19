enum ChessPieceTypes { pawn, rook, knight, bishop, queen, king }

enum Player { white, black }

class ChessPiece {
  final ChessPieceTypes type;
  final bool isWhite;
  ChessPiece({required this.type, required this.isWhite});
}
