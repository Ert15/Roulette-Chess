import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/position.dart';
import '../models/piece.dart';
import '../providers/game_state.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({super.key});

  static const _lightSquare  = Color(0xFFF0D9B5);
  static const _darkSquare   = Color(0xFFB58863);
  static const _selectedColor  = Color(0x9900CFFF);
  static const _validMoveColor = Color(0x9964C832);
  static const _lastMoveColor  = Color(0x88F6F669);
  static const _checkColor     = Color(0xAAFF3333);

  // Белые фигуры — почти белый с тёмной обводкой
  static const _whiteColor = Color(0xFFFFFAF0);
  // Чёрные фигуры — тёмно-коричневый/чёрный
  static const _blackColor = Color(0xFF1A0A00);

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final size = MediaQuery.of(context).size;
    final boardSize = size.width < size.height
        ? size.width - 32
        : size.height * 0.55;
    final cellSize = boardSize / 8;

    // Найти позицию короля под шахом
    Position? checkKingPos;
    if (game.isInCheck) {
      for (var r = 0; r < 8; r++) {
        for (var c = 0; c < 8; c++) {
          final p = game.board[r][c];
          if (p != null && p.type == PieceType.king && p.color == game.turn) {
            checkKingPos = Position(r, c);
          }
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: game.isInCheck ? Colors.red.shade600 : Colors.brown.shade800,
          width: game.isInCheck ? 3 : 2,
        ),
      ),
      child: SizedBox(
        width: boardSize,
        height: boardSize,
        child: Column(
          children: List.generate(8, (row) {
            return Row(
              children: List.generate(8, (col) {
                final pos = Position(row, col);
                final piece = game.board[row][col];
                final isLight = (row + col) % 2 == 0;
                final isSelected = game.selectedPos == pos;
                final isValidMove = game.validMoves.contains(pos);
                final isLastMove = game.lastFrom == pos || game.lastTo == pos;
                final isKingInCheck = checkKingPos == pos;

                return GestureDetector(
                  onTap: () => game.selectOrMove(pos),
                  child: Container(
                    width: cellSize,
                    height: cellSize,
                    color: isLight ? _lightSquare : _darkSquare,
                    child: Stack(
                      children: [
                        if (isKingInCheck)
                          Container(color: _checkColor),
                        if (isLastMove && !isKingInCheck)
                          Container(color: _lastMoveColor),
                        if (isSelected)
                          Container(color: _selectedColor),
                        if (isValidMove)
                          Center(
                            child: Container(
                              width: piece != null ? cellSize : cellSize * 0.35,
                              height: piece != null ? cellSize : cellSize * 0.35,
                              decoration: piece != null
                                  ? BoxDecoration(
                                      border: Border.all(color: _validMoveColor, width: 4),
                                    )
                                  : BoxDecoration(
                                      color: _validMoveColor,
                                      shape: BoxShape.circle,
                                    ),
                            ),
                          ),
                        if (piece != null)
                          Center(
                            child: Text(
                              piece.symbol,
                              style: TextStyle(
                                fontSize: cellSize * 0.72,
                                height: 1,
                                color: piece.color == PieceColor.white
                                    ? _whiteColor
                                    : _blackColor,
                                shadows: [
                                  Shadow(
                                    color: piece.color == PieceColor.white
                                        ? const Color(0xCC3A1A00)
                                        : const Color(0x88FFFFFF),
                                    blurRadius: 2,
                                    offset: const Offset(0.5, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Координаты
                        if (col == 0)
                          Positioned(
                            top: 2, left: 3,
                            child: Text(
                              '${8 - row}',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isLight ? _darkSquare : _lightSquare,
                              ),
                            ),
                          ),
                        if (row == 7)
                          Positioned(
                            bottom: 2, right: 3,
                            child: Text(
                              String.fromCharCode(97 + col),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isLight ? _darkSquare : _lightSquare,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}
