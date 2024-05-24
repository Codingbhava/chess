import 'package:chess/components/piece.dart';
import 'package:chess/helper/methods.dart';
import 'package:chess/utils/app_styles.dart';
import 'package:flutter/material.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final double size;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isValidMove;

  const Square(
      {Key? key,
      required this.isWhite,
      required this.piece,
      required this.size,
      required this.isSelected,
      required this.onTap,
      required this.isValidMove})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color squareColor = isSelected
        ? AppTheme.selectedColor
        : isValidMove
            ? AppTheme.selectedValidColor
            : isWhite
                ? AppTheme.white
                : AppTheme.black;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        color: squareColor,
        child: piece != null
            ? Image.asset(
                getImagePath(piece!),
                fit: BoxFit.contain,
              )
            : null,
      ),
    );
  }
}
