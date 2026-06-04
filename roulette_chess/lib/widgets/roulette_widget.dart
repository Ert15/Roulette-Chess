import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';

class RouletteWidget extends StatefulWidget {
  const RouletteWidget({super.key});

  @override
  State<RouletteWidget> createState() => _RouletteWidgetState();
}

class _RouletteWidgetState extends State<RouletteWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  Timer? _spinTimer;
  int _spinFrame = 0;
  bool _isSpinning = true;
  bool _resolved = false;
  final List<String> _spinEmojis = ['🔫', '💀', '🎲', '💥', '🎯', '🎰'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    _startSpin();
  }

  void _startSpin() {
    _spinTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (mounted) setState(() => _spinFrame++);
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted && !_resolved) _resolve();
    });
  }

  void _resolve() {
    _resolved = true;
    _spinTimer?.cancel();
    final game = context.read<GameState>();
    game.resolveRoulette();
    setState(() => _isSpinning = false);
  }

  @override
  void dispose() {
    _spinTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final piece = game.roulettePiece;

    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isSpinning
                ? Colors.orange.shade600
                : (game.rouletteResult ? Colors.red.shade400 : Colors.green.shade400),
            width: _isSpinning ? 1 : 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isSpinning
                  ? _spinEmojis[_spinFrame % _spinEmojis.length]
                  : (game.rouletteResult ? '💀' : '✅'),
              style: const TextStyle(fontSize: 44),
            ),
            const SizedBox(height: 6),
            if (piece != null)
              Text(
                '${piece.symbol} ${piece.name}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 4),
            Text(
              _isSpinning
                  ? 'Крутим барабан...'
                  : (game.rouletteResult
                      ? '☠️ Выпало ${game.rouletteDieNumber}/3 — ПОГИБЛА!'
                      : '✅ Выпало ${game.rouletteDieNumber}/3 — выжила!'),
              style: TextStyle(
                fontSize: 14,
                color: _isSpinning
                    ? Colors.orange.shade300
                    : (game.rouletteResult ? Colors.red : Colors.green),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              'Шанс смерти: 1/3',
              style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
