import 'package:chess/components/piece.dart';
import 'package:chess/components/square.dart';
import 'package:chess/helper/methods.dart';
import 'package:chess/utils/app_styles.dart';
import 'package:flutter/material.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late List<List<ChessPiece?>> board;
  ChessPiece? selectedPiece;
  int selectedRow = -1;
  int selectedCol = -1;
  List<List<int>> validMoves = [];
  Player currentPlayer = Player.white; // Start with white player
  List<ChessPiece> whiteKilledPieces = [];
  List<ChessPiece> blackKilledPieces = [];

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    // Initialize pieces (pawns, rooks, knights, bishops, queen, king)
    // Pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(type: ChessPieceTypes.pawn, isWhite: false);
      newBoard[6][i] = ChessPiece(type: ChessPieceTypes.pawn, isWhite: true);
    }

    // Rooks
    newBoard[0][0] = ChessPiece(type: ChessPieceTypes.rook, isWhite: false);
    newBoard[0][7] = ChessPiece(type: ChessPieceTypes.rook, isWhite: false);
    newBoard[7][0] = ChessPiece(type: ChessPieceTypes.rook, isWhite: true);
    newBoard[7][7] = ChessPiece(type: ChessPieceTypes.rook, isWhite: true);

    // Knights
    newBoard[0][1] = ChessPiece(type: ChessPieceTypes.knight, isWhite: false);
    newBoard[0][6] = ChessPiece(type: ChessPieceTypes.knight, isWhite: false);
    newBoard[7][1] = ChessPiece(type: ChessPieceTypes.knight, isWhite: true);
    newBoard[7][6] = ChessPiece(type: ChessPieceTypes.knight, isWhite: true);

    // Bishops
    newBoard[0][2] = ChessPiece(type: ChessPieceTypes.bishop, isWhite: false);
    newBoard[0][5] = ChessPiece(type: ChessPieceTypes.bishop, isWhite: false);
    newBoard[7][2] = ChessPiece(type: ChessPieceTypes.bishop, isWhite: true);
    newBoard[7][5] = ChessPiece(type: ChessPieceTypes.bishop, isWhite: true);

    // Queens
    newBoard[0][3] = ChessPiece(type: ChessPieceTypes.queen, isWhite: false);
    newBoard[7][3] = ChessPiece(type: ChessPieceTypes.queen, isWhite: true);

    // Kings
    newBoard[0][4] = ChessPiece(type: ChessPieceTypes.king, isWhite: false);
    newBoard[7][4] = ChessPiece(type: ChessPieceTypes.king, isWhite: true);

    board = newBoard;
  }

  void pieceSelected(int row, int col) {
    setState(() {
      bool select = board[row][col] != null &&
          board[row][col]!.isWhite == (currentPlayer == Player.white);
      if (select) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
        // Check if the selected piece is a king and if it is killed
        if (selectedPiece?.type == ChessPieceTypes.king &&
            ((currentPlayer == Player.white &&
                    blackKilledPieces.contains(selectedPiece!)) ||
                (currentPlayer == Player.black &&
                    whiteKilledPieces.contains(selectedPiece!)))) {
          return; // Don't calculate and show valid moves
        }
        validMoves = calculateRawValidMoves(
            selectedRow, selectedCol, selectedPiece, board);
      } else {
        if (isValidMove(row, col)) {
          // Check if a piece is being killed
          if (board[row][col] != null) {
            if (currentPlayer == Player.white) {
              blackKilledPieces.add(board[row][col]!);
            } else {
              whiteKilledPieces.add(board[row][col]!);
            }
          }
          // Handle pawn reaching the end of the board
          if (selectedPiece!.type == ChessPieceTypes.pawn &&
              (row == 0 || row == 7)) {
            _showPromotionDialog(row, col);
          } else {
            // Move the selected piece to the new position
            board[row][col] = selectedPiece;
            board[selectedRow][selectedCol] = null;
            // Deselect the piece after moving
            selectedPiece = null;
            selectedRow = -1;
            selectedCol = -1;
            validMoves = [];
            // Switch player after move
            currentPlayer =
                currentPlayer == Player.white ? Player.black : Player.white;
          }
        }
      }
    });
    checkForWinner();
  }

  void _showPromotionDialog(int row, int col) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentTextStyle: TextStyle(color: AppTheme.textColor),
          backgroundColor: Colors.black,
          title: Text(
            "Pawn Promotion",
            style: TextStyle(color: AppTheme.textColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Choose a piece to promote your pawn:",
                style: TextStyle(color: AppTheme.textColor),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      promotePawn(row, col, ChessPieceTypes.queen);
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Image.asset(
                      getImagePath(ChessPiece(
                          type: ChessPieceTypes.queen,
                          isWhite: currentPlayer == Player.white)),
                      fit: BoxFit.contain,
                      width: 40,
                      height: 40,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      promotePawn(row, col, ChessPieceTypes.rook);
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Image.asset(
                      getImagePath(ChessPiece(
                          type: ChessPieceTypes.rook,
                          isWhite: currentPlayer == Player.white)),
                      fit: BoxFit.contain,
                      width: 40,
                      height: 40,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      promotePawn(row, col, ChessPieceTypes.knight);
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Image.asset(
                      getImagePath(ChessPiece(
                          type: ChessPieceTypes.knight,
                          isWhite: currentPlayer == Player.white)),
                      fit: BoxFit.contain,
                      width: 40,
                      height: 40,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      promotePawn(row, col, ChessPieceTypes.bishop);
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Image.asset(
                      getImagePath(ChessPiece(
                          type: ChessPieceTypes.bishop,
                          isWhite: currentPlayer == Player.white)),
                      fit: BoxFit.contain,
                      width: 40,
                      height: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  bool isValidMove(int row, int col) {
    return validMoves.any((move) => move[0] == row && move[1] == col);
  }

  void checkForWinner() {
    bool whiteKingExists = false;
    bool blackKingExists = false;

    // Check if both kings are still on the board
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (board[row][col]?.type == ChessPieceTypes.king) {
          if (board[row][col]?.isWhite == true) {
            whiteKingExists = true;
          } else {
            blackKingExists = true;
          }
        }
      }
    }

    if (!whiteKingExists) {
      showWinnerDialog("Black");
    } else if (!blackKingExists) {
      showWinnerDialog("White");
    }
  }
void showWinnerDialog(String winner) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        contentTextStyle: TextStyle(color: AppTheme.textColor),
        backgroundColor: Colors.black,
        title: Text(
          "Game Over",
          style: TextStyle(color: AppTheme.textColor),
        ),
        content: Text("$winner wins!"),
        actions: [
          TextButton(
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(AppTheme.panelColor)),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              resetGame();
            },
            child:
                Text("Reset Game", style: TextStyle(color: AppTheme.textColor)),
          ),
        ],
      );
    },
  );
}
  void promotePawn(int row, int col, ChessPieceTypes type) {
    setState(() {
      board[row][col] =
          ChessPiece(type: type, isWhite: currentPlayer == Player.white);
      board[selectedRow][selectedCol] = null;
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
      // Switch player after promotion
      currentPlayer =
          currentPlayer == Player.white ? Player.black : Player.white;
    });
  }

  void resetGame() {
    setState(() {
      _initializeBoard();
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
      currentPlayer = Player.white;
      whiteKilledPieces.clear();
      blackKilledPieces.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = currentPlayer == Player.white
        ? AppTheme.white
        : AppTheme
            .panelColor; // Define background color based on current player
    Color backgroundColorbutton =
        currentPlayer == Player.white ? AppTheme.panelColor : AppTheme.white;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: backgroundColorbutton,
          onPressed: resetGame,
          child: Icon(
            Icons.restart_alt,
            color: backgroundColor,
          )),
      backgroundColor: backgroundColor, // Set background color
      body: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: Text(
              currentPlayer == Player.white ? 'White Turn' : 'Black Turn',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color:
                    currentPlayer == Player.white ? Colors.black : Colors.white,
              ),
            ),
          ),
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final squareSize = calculateSquareSize(context);
                final boardSize = squareSize * 8;

                return Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.brown[700], // Wood color
                    border: Border.all(
                      color: Colors.brown[800]!, // Border color
                      width: 8.0, // Border width
                    ),
                  ),
                  width: boardSize,
                  height: boardSize,
                  child: GridView.builder(
                    itemCount: 8 * 8,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      int row = index ~/ 8;
                      int col = index % 8;
                      bool isSelected =
                          selectedRow == row && selectedCol == col;
                      bool isValidMove = validMoves
                          .any((move) => move[0] == row && move[1] == col);
                      return Square(
                        onTap: () => pieceSelected(row, col),
                        isWhite: isWhite(index),
                        piece: board[row][col],
                        size: squareSize,
                        isValidMove: isValidMove,
                        isSelected: isSelected,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
