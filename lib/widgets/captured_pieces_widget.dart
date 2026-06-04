import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/piece.dart';
import '../providers/game_state.dart';

class CapturedPiecesWidget extends StatelessWidget {
  final PieceColor color;

  const CapturedPiecesWidget({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final pieces = color == PieceColor.white
        ? game.capturedByWhite
        : game.capturedByBlack;

    return Row(
      children: [
        Text(
          color == PieceColor.white ? 'Белые: ' : 'Чёрные: ',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            pieces.map((p) => p.symbol).join(' '),
            style: const TextStyle(fontSize: 14, letterSpacing: 1),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
