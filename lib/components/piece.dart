import 'package:chess/helper/methods.dart';
import 'package:chess/utils/app_styles.dart';
import 'package:flutter/material.dart';

enum ChessPieceTypes { pawn, rook, knight, bishop, queen, king }

enum Player { white, black }

class ChessPiece {
  final ChessPieceTypes type;
  final bool isWhite;
  ChessPiece({required this.type, required this.isWhite});
}

class DeadPiece extends StatelessWidget {
  final ChessPiece? piece;
  final double size;
  const DeadPiece({
    super.key,
    required this.piece,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: piece!.isWhite ? AppTheme.white : AppTheme.black,
      child: piece != null
          ? Image.asset(
              getImagePath(piece!),
              fit: BoxFit.contain,
            )
          : null,
    );
  }
}
