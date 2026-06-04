import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../widgets/board_widget.dart';
import '../widgets/roulette_widget.dart';
import '../widgets/move_log_widget.dart';
import '../widgets/captured_pieces_widget.dart';
import '../models/piece.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Text('♟ ', style: TextStyle(fontSize: 22)),
            Text('Roulette Chess', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            SizedBox(width: 8),
            Text('🔫', style: TextStyle(fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Новая игра',
            onPressed: () => _confirmReset(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isWide
          ? _buildWideLayout(context, game)
          : _buildNarrowLayout(context, game),
    );
  }

  Widget _buildWideLayout(BuildContext context, GameState game) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CapturedPiecesWidget(color: PieceColor.white),
              const SizedBox(height: 6),
              const BoardWidget(),
              const SizedBox(height: 6),
              CapturedPiecesWidget(color: PieceColor.black),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
            child: Column(
              children: [
                _buildStatusCard(context, game),
                if (game.phase == GamePhase.roulette) ...[
                  const SizedBox(height: 12),
                  const RouletteWidget(),
                ],
                const SizedBox(height: 12),
                const Expanded(child: MoveLogWidget()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context, GameState game) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildStatusCard(context, game),
          if (game.phase == GamePhase.roulette) ...[
            const SizedBox(height: 10),
            const RouletteWidget(),
          ],
          const SizedBox(height: 10),
          CapturedPiecesWidget(color: PieceColor.white),
          const SizedBox(height: 4),
          const BoardWidget(),
          const SizedBox(height: 4),
          CapturedPiecesWidget(color: PieceColor.black),
          const SizedBox(height: 10),
          SizedBox(height: 200, child: const MoveLogWidget()),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, GameState game) {
    if (game.phase == GamePhase.gameOver) {
      final isRealWinner = game.winner != 'Ничья (пат)';
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isRealWinner
                ? [Colors.purple.shade900, Colors.purple.shade700]
                : [Colors.blueGrey.shade900, Colors.blueGrey.shade700],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(isRealWinner ? '🏆' : '🤝', style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              isRealWinner ? 'Победа: ${game.winner}!' : game.winner!,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => game.resetGame(),
              icon: const Icon(Icons.replay),
              label: const Text('Новая игра'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.purple.shade900,
              ),
            ),
          ],
        ),
      );
    }

    final isWhiteTurn = game.turn == PieceColor.white;
    final inCheck = game.isInCheck;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: inCheck
            ? Colors.red.shade900
            : (isWhiteTurn ? const Color(0xFFF0D9B5) : const Color(0xFF2C2C2C)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: inCheck
              ? Colors.red.shade400
              : (isWhiteTurn ? const Color(0xFFB58863) : const Color(0xFF5A5A5A)),
          width: inCheck ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            isWhiteTurn ? '♚' : '♚',
            style: TextStyle(
              fontSize: 28,
              color: isWhiteTurn
                  ? (inCheck ? Colors.white : const Color(0xFF1A0A00))
                  : Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inCheck
                      ? '⚠️ ШАХ! ${isWhiteTurn ? "Белые" : "Чёрные"}'
                      : 'Ход: ${isWhiteTurn ? "Белые" : "Чёрные"}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: inCheck
                        ? Colors.white
                        : (isWhiteTurn ? const Color(0xFF3A2A0A) : Colors.white),
                  ),
                ),
                Text(
                  game.phase == GamePhase.roulette
                      ? '🔫 Рулетка (1/3 смерти)...'
                      : inCheck
                          ? 'Защитите короля!'
                          : 'Выберите фигуру',
                  style: TextStyle(
                    fontSize: 12,
                    color: inCheck
                        ? Colors.red.shade200
                        : (isWhiteTurn ? const Color(0xFF6A4A2A) : Colors.grey.shade400),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade700),
            ),
            child: Text(
              '♚♛ иммун',
              style: TextStyle(fontSize: 11, color: Colors.amber.shade700, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Новая игра?'),
        content: const Text('Текущая партия будет сброшена.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<GameState>().resetGame();
            },
            child: const Text('Начать заново'),
          ),
        ],
      ),
    );
  }
}
